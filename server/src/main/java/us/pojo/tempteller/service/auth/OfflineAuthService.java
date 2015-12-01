package us.pojo.tempteller.service.auth;

import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.auth.Receipt;
import us.pojo.tempteller.model.auth.User;

/**
 * Dummy implementation of the AuthService..no db involved.
 * @author ben
 */
@Service(value="AuthService")
@Profile(value="offline")
public class OfflineAuthService extends BaseAuthService implements AuthService {

	Map<String,User> users = new ConcurrentHashMap<>();
	private Map<String,User> txns = new ConcurrentHashMap<>();
	
	@Override
	protected void saveUser(User user) {
		users.put(user.getUid(), user);
	}
	
	@Override
	protected User getUser(String uid) {
		return users.get(uid);
	}
	
	@Override
	protected User getUserFromTxns(Receipt receipt) {
		 Optional<String> txn = receipt.getTxnIds().stream().filter(txnId -> txns.containsKey(txnId)).findAny();
		 User user = null;
		 if (txn.isPresent()) {
			 user = txns.get(txn.get());
		 }
		 return user;
	}
	
	@Override
	protected void saveTxns(Receipt receipt, User user) {
		 receipt.getTxnIds().stream().forEach(txnId -> txns.putIfAbsent(txnId, user));
	}
}
