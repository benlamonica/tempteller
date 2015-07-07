package us.pojo.weathernotifier.model;

import java.io.Serializable;

public class WOEID implements Serializable {
	private static final long serialVersionUID = 1L;

	private String WOEID;
	
	public WOEID(String woeId) {
		WOEID = woeId;
	}
	
	public String getWOEID() {
		return WOEID;
	}
}
