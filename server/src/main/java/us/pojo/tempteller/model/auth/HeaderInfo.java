package us.pojo.tempteller.model.auth;

import java.util.HashMap;
import java.util.TimeZone;

public class HeaderInfo extends HashMap<String, Object> {
	private static final long serialVersionUID = 1L;
	private String uid;
	private String pushToken;
	private String deviceId;
	private String tz;
	
	@Override
	public Object put(String key, Object value) {
		switch(key.toLowerCase()) {
			case "tz": this.tz = (String) value; break;
			case "pushtoken": this.pushToken = (String) value; break;
			case "uid": this.uid = (String) value; break;
			case "deviceid": this.deviceId = (String) value; break;
		}
		return null;
	}
	
	public String getDeviceId() {
		return deviceId;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public String getPushToken() {
		return pushToken;
	}

	public void setPushToken(String pushToken) {
		this.pushToken = pushToken;
	}

	public String getTz() {
		return tz;
	}
	
	public TimeZone getTimeZone() {
		if (tz != null) {
			return TimeZone.getTimeZone(tz);
		} else {
			return TimeZone.getDefault();
		}
	}

	public void setTz(String tz) {
		this.tz = tz;
	}
}
