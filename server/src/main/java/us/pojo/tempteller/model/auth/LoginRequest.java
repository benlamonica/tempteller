package us.pojo.tempteller.model.auth;

public class LoginRequest {
	public String uid;
	public String pushToken;
	public String priorPushToken;
	public String timezone;
	
	public LoginRequest(String uid, String pushToken, String priorPushToken, String timezone) {
		this.uid = uid;
		this.pushToken = pushToken;
		this.priorPushToken = priorPushToken;
		this.timezone = timezone;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((priorPushToken == null) ? 0 : priorPushToken.hashCode());
		result = prime * result + ((pushToken == null) ? 0 : pushToken.hashCode());
		result = prime * result + ((timezone == null) ? 0 : timezone.hashCode());
		result = prime * result + ((uid == null) ? 0 : uid.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		LoginRequest other = (LoginRequest) obj;
		if (priorPushToken == null) {
			if (other.priorPushToken != null)
				return false;
		} else if (!priorPushToken.equals(other.priorPushToken))
			return false;
		if (pushToken == null) {
			if (other.pushToken != null)
				return false;
		} else if (!pushToken.equals(other.pushToken))
			return false;
		if (timezone == null) {
			if (other.timezone != null)
				return false;
		} else if (!timezone.equals(other.timezone))
			return false;
		if (uid == null) {
			if (other.uid != null)
				return false;
		} else if (!uid.equals(other.uid))
			return false;
		return true;
	}
}
