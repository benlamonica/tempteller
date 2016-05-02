package us.pojo.tempteller.model.auth;

import java.util.TimeZone;

public class HeaderInfo {
	private String uid;
	private String pushToken;
	private String deviceId;
	private String tz;

	public HeaderInfo(String uid, String pushToken, String deviceId, String tz) {
		this.uid = uid;
		this.pushToken = pushToken;
		this.deviceId = deviceId;
		this.tz = tz;
	}
	
	public String getDeviceId() {
		return deviceId;
	}

	public String getUid() {
		return uid;
	}

	public String getPushToken() {
		return pushToken;
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
}
