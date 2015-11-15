package us.pojo.tempteller.service.auth;

import java.text.SimpleDateFormat;
import java.util.Base64;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.Receipt;
import us.pojo.tempteller.model.auth.UserInfo;
import us.pojo.tempteller.service.rule.RuleService;
import us.pojo.tempteller.util.ReceiptParser;

/**
 * Dummy implementation of the AuthService..no db involved.
 * @author ben
 */
@Service(value="AuthService")
public class OfflineAuthService implements AuthService {

	private ReceiptParser receiptParser = new ReceiptParser();
	
	@Autowired
	private RuleService ruleService;
	
	public void setRuleService(RuleService ruleService) {
		this.ruleService = ruleService;
	}
	
	private static class User {
		public Date subEndDate;
		public String uid;
	}
	
	private static final Logger log = LoggerFactory.getLogger(OfflineAuthService.class);
	private Map<String,User> users = new ConcurrentHashMap<>();
	private Map<String,User> txns = new ConcurrentHashMap<>();
	
	@Override
	public AuthResult login(UserInfo userInfo) {
		User user;
		if (userInfo.uid != null && users.containsKey(userInfo.uid)) {
			user = users.get(userInfo.uid);
		} else {
			Calendar cal = Calendar.getInstance();
			cal.add(Calendar.DAY_OF_MONTH, 10);
			user = new User();
			user.subEndDate = new Date(System.currentTimeMillis() + (7 * 24 * 60 * 60 * 1000));
			user.uid = UUID.randomUUID().toString();
			log.info("Creating New User uid: {}, subEndDate: {}", user.uid, user.subEndDate);
			users.put(user.uid, user);
		}

		if (userInfo.priorPushToken != null && !userInfo.priorPushToken.equals(userInfo.pushToken)) {
			log.info("Updating uid: {} pushtoken from {} to {}", userInfo.uid, userInfo.priorPushToken, userInfo.pushToken);
			ruleService.updatePushToken(userInfo.uid, userInfo.priorPushToken, userInfo.pushToken);
		}
		
		return getAuthResult(user, "");
	}

	private AuthResult getAuthResult(User user, String msg) {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		return new AuthResult(user.uid, df.format(user.subEndDate),"");
	}
	
	@Override
	public AuthResult addSubscription(String uid, String deviceId, String pkcs7receipt) {
		 log.info("adding subscription with receipt: '{}'",pkcs7receipt);
		 byte[] rbytes = Base64.getDecoder().decode(pkcs7receipt);
		 try {
			 User user = users.get(uid);
			 if (user == null) {
				 return new AuthResult(uid, "Not Subscribed", "{USER_NOT_FOUND}");
			 }

			 List<Map<String,String>> parsed = receiptParser.parsePurchases(rbytes, deviceId);
			 Receipt receipt = new Receipt(parsed);
			 receipt.getTxnIds().stream().forEach(txnId -> txns.putIfAbsent(txnId, user));
			 user.subEndDate = receipt.getSubEndDate();
			 return getAuthResult(user, "");
		 } catch (Exception e) {
			 log.error("Failed to parse receipt {}" + pkcs7receipt, e);
			 return new AuthResult(uid, "Not Subscribed", "{RECEIPT_READ_ERROR}");
		 }
	}

	@Override
	public AuthResult restoreSubscription(String deviceId, String pkcs7receipt) {
		log.info("restoring subscription with receipt: '{}", pkcs7receipt);
		 byte[] rbytes = Base64.getDecoder().decode(pkcs7receipt);
		 try {
			 List<Map<String,String>> parsed = receiptParser.parsePurchases(rbytes, deviceId);
			 Receipt receipt = new Receipt(parsed);
			 Optional<String> txn = receipt.getTxnIds().stream().filter(txnId -> txns.containsKey(txnId)).findAny();
			 if (txn.isPresent()) {
				 User user = txns.get(txn.get());
				 user.subEndDate = receipt.getSubEndDate();
				 return getAuthResult(user, "");
			 } else {
				 return new AuthResult("-1", "Not Subscribed", "{COULD_NOT_FIND_USER}");
			 }
		 } catch (Exception e) {
			 log.error("Failed to parse receipt {}" + pkcs7receipt, e);
			 return new AuthResult("-1", "Not Subscribed", "{RECEIPT_READ_ERROR}");
		 }
	}

}
