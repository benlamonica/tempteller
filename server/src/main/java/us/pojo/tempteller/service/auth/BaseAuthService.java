package us.pojo.tempteller.service.auth;

import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.LoginRequest;
import us.pojo.tempteller.model.auth.Receipt;
import us.pojo.tempteller.model.auth.User;
import us.pojo.tempteller.service.rule.RuleService;
import us.pojo.tempteller.util.ReceiptParser;

public abstract class BaseAuthService implements AuthService {

	protected abstract void saveTxns(Receipt receipt, User user);

	protected abstract User getUserFromTxns(Receipt receipt);

	protected abstract User getUser(String uid);

	protected abstract void saveUser(User user);

	private ReceiptParser receiptParser = new ReceiptParser();
	
	@Autowired
	private RuleService ruleService;

	public void setRuleService(RuleService ruleService) {
		this.ruleService = ruleService;
	}

	private final Logger log = LoggerFactory.getLogger(getClass());

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


}
