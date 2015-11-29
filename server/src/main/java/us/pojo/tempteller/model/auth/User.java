package us.pojo.tempteller.model.auth;

import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.Id;

@Entity
public class User {
	@Id
	private String uid;
	private Date subEndDate;

	protected User() { }
	
	public User(String uid, Date subEndDate) {
		this.uid = uid;
		this.subEndDate = subEndDate;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public Date getSubEndDate() {
		return subEndDate;
	}

	public void setSubEndDate(Date subEndDate) {
		this.subEndDate = subEndDate;
	}
	
	
}
