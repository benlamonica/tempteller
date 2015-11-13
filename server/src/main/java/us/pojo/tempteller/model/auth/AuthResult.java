package us.pojo.tempteller.model.auth;

public class AuthResult {
	public String uid;
	public String msg;
	public String subEndDate;
	public AuthResult(String uid, String subEndDate, String msg) {
		this.uid = uid;
		this.subEndDate = subEndDate;
		this.msg = msg;
	}
	
	@Override
	public String toString() {
		return "AuthResult [uid=" + uid + ", msg=" + msg + ", subEndDate=" + subEndDate + "]";
	}
}
