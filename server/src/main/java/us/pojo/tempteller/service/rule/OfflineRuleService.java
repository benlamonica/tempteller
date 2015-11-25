package us.pojo.tempteller.service.rule;

import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.ReadLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.WriteLock;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.Rule;

@Service(value="RuleService")
public class OfflineRuleService implements RuleService {

	private ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
	private ReadLock readLock = lock.readLock();
	private WriteLock writeLock = lock.writeLock();
	private TreeMap<String, NotifiableRule> rules = new TreeMap<>();

	@Override
	public void updateTz(String uid, String pushToken, TimeZone tz) {
		readLock.lock();
		try {
			getRules(uid).stream()
				.filter(f -> pushToken.equals(f.pushToken))
				.forEach(r -> r.tz = tz);
		} finally {
			readLock.unlock();
		}
	}

	@Override
	public void saveRule(String uid, String pushToken, Rule rule, TimeZone tz) {
		String key = uid+"_"+pushToken+"_"+rule.getUuid();

		writeLock.lock();
		try {
			NotifiableRule nrule = rules.get(key);
			
			if (nrule == null) {
				nrule = new NotifiableRule();
				nrule.lastNotify = null;
				nrule.pushToken = pushToken;
				nrule.rule = rule;
				nrule.tz = tz;
				nrule.uid = uid;
				rules.put(uid+"_"+pushToken+"_"+rule.getUuid(), nrule);
			} else {
				nrule.rule = rule;
				nrule.tz = tz;
			}
		} finally {
			writeLock.unlock();
		}
	}

	@Override
	public void delete(String uid, String pushToken, String ruleId) {
		String key = uid+"_"+pushToken+"_"+ruleId;
		writeLock.lock();
		try {
			rules.remove(key);
		} finally {
			writeLock.unlock();
		}
	}

	@Override
	public List<NotifiableRule> getRules(String uid) {
		readLock.lock();
		try {
			// we append a "`" to the uid because the keys are uid_pushToken_ruleId, so we 
			// pick the character right after a '_' to grab all of the users rules...
			return rules.subMap(uid, uid + "`").values().stream()
				.filter(f -> f.uid == uid) // this shouldn't be necessary, but just in case!
				.collect(Collectors.toList());
		} finally {
			readLock.unlock();
		}
	}

	@Override
	public List<NotifiableRule> getActiveRules() {
		readLock.lock();
		try {
			return rules.values().stream()
				.filter(f -> f.isActive(new Date()))
				.collect(Collectors.toList());
		} finally {
			readLock.unlock();
		}
	}

	@Override
	public void updatePushToken(String uid, String priorPushToken, String pushToken) {
		writeLock.lock();
		try {
			getRules(uid).stream()
				.filter(r -> r.pushToken.equals(priorPushToken))
				.forEach(r -> r.pushToken = pushToken);
		} finally {
			writeLock.unlock();
		}
	}

	@Override
	public void transferPushTokenToNewUid(String uid, String uid2, String pushToken) {
		writeLock.lock();
		try {
			getRules(uid).stream()
				.filter(r -> r.pushToken.equals(pushToken))
				.forEach(r -> r.pushToken = pushToken);
		} finally {
			writeLock.unlock();
		}
	}

}
