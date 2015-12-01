package us.pojo.tempteller.service.auth;

import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.auth.Receipt;
import us.pojo.tempteller.model.auth.Transaction;
import us.pojo.tempteller.model.auth.User;
import us.pojo.tempteller.service.repository.TransactionRepository;
import us.pojo.tempteller.service.repository.UserRepository;

@Service(value="AuthService")
public class DefaultAuthService extends BaseAuthService implements AuthService {
	@Autowired
	private TransactionRepository txns;
	
	@Autowired
	private UserRepository users;
	
	@Override
	protected void saveTxns(Receipt receipt, User user) {
		txns.save(receipt.getTxnIds().stream()
				.map(txn -> new Transaction(txn, user))
				.collect(Collectors.toList()));
	}

	@Override
	protected User getUserFromTxns(Receipt receipt) {
		Iterable<Transaction> result = txns.findAll(receipt.getTxnIds());
		Optional<Transaction> txn = StreamSupport.stream(result.spliterator(), false).findFirst();
		if (txn.isPresent()) {
			return txn.get().getUser();
		} else {
			return null;
		}
	}

	@Override
	protected User getUser(String uid) {
		return users.findOne(uid);
	}

	@Override
	protected void saveUser(User user) {
		users.save(user);
	}

}
