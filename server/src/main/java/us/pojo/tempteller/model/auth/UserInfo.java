package us.pojo.tempteller.model.auth;

public class UserInfo {
	public String uid;
	public String pushToken;
	public String priorPushToken;
	
	public UserInfo(String uid, String pushToken, String priorPushToken) {
		this.uid = uid;
		this.pushToken = pushToken;
		this.priorPushToken = priorPushToken;
	}
}
