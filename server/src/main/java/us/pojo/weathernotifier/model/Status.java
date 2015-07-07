package us.pojo.weathernotifier.model;

import java.io.Serializable;

public class Status implements Serializable {

	private static final long serialVersionUID = 1L;

	private String status;
	
	private String woeId;
	
	private String deviceId;
	
	public Status(String deviceId, String woeId, String status) {
		this.woeId = woeId;
		this.deviceId = deviceId;
		this.status = status;
	}
	
	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public String getWoeId() {
		return woeId;
	}

	public String getDeviceId() {
		return deviceId;
	}

	public String getStatus() {
		return status;
	}
}
