package us.pojo.tempteller.model.auth;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.ManyToOne;

@Entity
public class Transaction {

	@Id
	private String id;
	private User user;
	
	protected Transaction() { }
	
	public Transaction(String transactionId, User user) {
		this.user = user;
		this.id = transactionId;
	}

	public String getTransactionId() {
		return id;
	}

	public void setTransactionId(String transactionId) {
		this.id = transactionId;
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}
	
	
}
