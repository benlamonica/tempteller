package us.pojo.tempteller.service.rule;

import java.util.Date;
import java.util.List;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.ReadLock;
import java.util.concurrent.locks.ReentrantReadWriteLock.WriteLock;
import java.util.stream.Collectors;

import javax.transaction.Transactional;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;

import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.NotifiableRule.RuleId;
import us.pojo.tempteller.model.rule.Rule;
import us.pojo.tempteller.service.repository.RuleRepository;

@Service(value="RuleService")
public class CachingRuleService implements RuleService, InitializingBean {

	@Autowired
	private RuleRepository ruleRepo;
	
	public void setRuleRepository(RuleRepository ruleRepo) {
		this.ruleRepo = ruleRepo;
	}
	
	private ReentrantReadWriteLock lock = new ReentrantReadWriteLock();
	private ReadLock readLock = lock.readLock();
	private WriteLock writeLock = lock.writeLock();
	private TreeMap<String, NotifiableRule> rules = new TreeMap<>();

	@Autowired(required=true)
	private PlatformTransactionManager txnManager;

	
	public void setTxnManager(PlatformTransactionManager txnManager) {
		this.txnManager = txnManager;
	}

	@Override
	public void updateTz(String uid, String pushToken, TimeZone tz) {
		readLock.lock();
		try {
			getRules(uid).stream()
				.filter(f -> pushToken.equals(f.getPushToken()))
				.forEach(r -> { r.setTimezone(tz); ruleRepo.save(r); });
		} finally {
			readLock.unlock();
		}
	}

	
	@Transactional
	public void saveRule(String uid, String pushToken, Rule rule, TimeZone tz) {
		NotifiableRule nrule = addRule(uid, pushToken, rule, tz);
		ruleRepo.save(nrule);
	}
	
	private NotifiableRule addRule(NotifiableRule nrule) {
		return addRule(nrule.getUid(), nrule.getPushToken(), nrule.getRule(), nrule.getTimeZone());
	}
	
	private NotifiableRule addRule(String uid, String pushToken, Rule rule, TimeZone tz) {
		String key = uid+"_"+pushToken+"_"+rule.getUuid();

		writeLock.lock();
		try {
			NotifiableRule nrule = rules.get(key);
			
			if (nrule == null) {
				nrule = new NotifiableRule();
				nrule.setLastNotify(null);
				nrule.setPushToken(pushToken);
				nrule.setRule(rule);
				nrule.setTimezone(tz);
				nrule.setUid(uid);
				nrule.setRuleId(rule.getUuid());
				rules.put(key, nrule);
			} else {
				nrule.setRule(rule);
				nrule.setTimezone(tz);
			}
			
			return nrule;
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
				.filter(f -> f.getUid().equals(uid)) // this shouldn't be necessary, but just in case!
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
	@Transactional
	public void updatePushToken(String uid, String priorPushToken, String pushToken) {
		writeLock.lock();
		try {
			List<NotifiableRule> rulesToMove = getRules(uid).stream()
				.filter(r -> r.getPushToken().equals(priorPushToken))
				.collect(Collectors.toList());
			
			rulesToMove.forEach(r -> {
				String key = r.getUid()+"_"+r.getPushToken()+"_"+r.getRuleId();
				rules.remove(key);
				ruleRepo.delete(new RuleId(r.getUid(), r.getPushToken(), r.getRuleId()));
				key = r.getUid()+"_"+pushToken+"_"+r.getRuleId();
				r.setPushToken(pushToken);
				rules.put(key, r);
				ruleRepo.save(r);
			});
		} finally {
			writeLock.unlock();
		}
	}

	@Override
	@Transactional
	public void transferPushTokenToNewUid(String fromUid, String toUid, String pushToken) {
		writeLock.lock();
		try {
			List<NotifiableRule> rulesToMove = getRules(fromUid).stream()
				.filter(r -> r.getPushToken().equals(pushToken))
				.collect(Collectors.toList());
			
			rulesToMove.forEach(r -> {
				String key = r.getUid()+"_"+r.getPushToken()+"_"+r.getRuleId();
				rules.remove(key);
				ruleRepo.delete(new RuleId(r.getUid(), r.getPushToken(), r.getRuleId()));
				key = toUid+"_"+pushToken+"_"+r.getRuleId();
				r.setUid(toUid);
				rules.put(key, r);
				ruleRepo.save(r);
			});
		} finally {
			writeLock.unlock();
		}
	}

	@Override
	public void afterPropertiesSet() throws Exception {
		TransactionStatus txn = txnManager.getTransaction(new DefaultTransactionDefinition(DefaultTransactionDefinition.PROPAGATION_NOT_SUPPORTED));
		writeLock.lock();
		try {
			ruleRepo.streamAllRules().forEach(r -> addRule(r));
		} finally {
			writeLock.unlock();
			txnManager.commit(txn);
		}
	}

}
