package us.pojo.tempteller.service.auth;

import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.transaction.Transactional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.LoginRequest;
import us.pojo.tempteller.model.auth.Receipt;
import us.pojo.tempteller.model.auth.Transaction;
import us.pojo.tempteller.model.auth.User;
import us.pojo.tempteller.service.repository.TransactionRepository;
import us.pojo.tempteller.service.repository.UserRepository;
import us.pojo.tempteller.service.rule.RuleService;
import us.pojo.tempteller.util.ReceiptParser;

@Service(value="AuthService")
public class PersistentAuthService implements AuthService {

	private ReceiptParser receiptParser = new ReceiptParser();
	
	@Autowired
	private RuleService ruleService;

	public void setRuleService(RuleService ruleService) {
		this.ruleService = ruleService;
	}

	private final Logger log = LoggerFactory.getLogger(getClass());

	@Autowired
	private TransactionRepository txns;

	@Autowired
	private UserRepository users;
	
	public void setTxns(TransactionRepository txns) {
		this.txns = txns;
	}

	public void setUsers(UserRepository users) {
		this.users = users;
	}

	@Transactional
	@Override
	public AuthResult login(LoginRequest userInfo) {
		User user = getUser(userInfo.uid);
		if (user == null) {
			Calendar cal = Calendar.getInstance();
			cal.add(Calendar.DAY_OF_MONTH, 10);
			user = new User(UUID.randomUUID().toString(), new Date(System.currentTimeMillis() + (7 * 24 * 60 * 60 * 1000)));
			log.info("Creating New User uid: {}, subEndDate: {}", user.getUid(), user.getSubEndDate());
			saveUser(user);
		}
	
		if (userInfo.priorPushToken != null && !userInfo.priorPushToken.equals(userInfo.pushToken)) {
			log.info("Updating uid: {} pushtoken from {} to {}", userInfo.uid, userInfo.priorPushToken, userInfo.pushToken);
			ruleService.updatePushToken(userInfo.uid, userInfo.priorPushToken, userInfo.pushToken);
		}
		
		return getAuthResult(user, "OK");
	}

	private AuthResult getAuthResult(User user, String msg) {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		return new AuthResult(user.getUid(), df.format(user.getSubEndDate()),msg);
	}

	@Transactional
	@Override
	public AuthResult addSubscription(String uid, String deviceId, String pkcs7receipt) {
		 log.info("adding subscription with receipt: '{}'",pkcs7receipt);
		 byte[] rbytes = Base64.getDecoder().decode(pkcs7receipt);
		 try {
			 User user = getUser(uid);
			 if (user == null) {
				 return new AuthResult(uid, "Not Subscribed", "{USER_NOT_FOUND}");
			 }
	
			 List<Map<String,String>> parsed = receiptParser.parsePurchases(rbytes, deviceId);
			 log.info("Parsed Receipt: {}", parsed);
			 Receipt receipt = new Receipt(parsed);
			 saveTxns(receipt, user);
			 user.setSubEndDate(receipt.getSubEndDate());
			 
			 return getAuthResult(user, "OK");
		 } catch (Exception e) {
			 log.error("Failed to parse receipt {}" + pkcs7receipt, e);
			 return new AuthResult(uid, "Not Subscribed", "{RECEIPT_READ_ERROR}");
		 }
	}

	@Transactional
	@Override
	public AuthResult restoreSubscription(String uid, String deviceId, String pkcs7receipt) {
		log.info("restoring subscription with receipt: '{}", pkcs7receipt);
		 byte[] rbytes = Base64.getDecoder().decode(pkcs7receipt);
		 try {
			 List<Map<String,String>> parsed = receiptParser.parsePurchases(rbytes, deviceId);
			 Receipt receipt = new Receipt(parsed);
			 User user = getUserFromTxns(receipt);
			 if (user != null) {
				 user.setSubEndDate(receipt.getSubEndDate());
				 return getAuthResult(user, "OK");
			 } else {
				 user = new User(uid, receipt.getSubEndDate());
				 saveUser(user);
				 saveTxns(receipt, user);
				 return getAuthResult(user,"OK");
			 }
		 } catch (Exception e) {
			 log.error("Failed to parse receipt {}" + pkcs7receipt, e);
			 return new AuthResult("-1", "Not Subscribed", "{RECEIPT_READ_ERROR}");
		 }
	}

	protected void saveTxns(Receipt receipt, User user) {
		txns.save(receipt.getTxnIds().stream()
				.map(txn -> new Transaction(txn, user))
				.collect(Collectors.toList()));
	}

	protected User getUserFromTxns(Receipt receipt) {
		Iterable<Transaction> result = txns.findAll(receipt.getTxnIds());
		Optional<Transaction> txn = StreamSupport.stream(result.spliterator(), false).findFirst();
		if (txn.isPresent()) {
			return txn.get().getUser();
		} else {
			return null;
		}
	}

	protected User getUser(String uid) {
		return users.findOne(uid);
	}

	protected void saveUser(User user) {
		users.save(user);
	}


}
