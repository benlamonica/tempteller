package us.pojo.weathernotifier.service;

import java.util.Set;

public interface PushService {
	void push(String msg, String deviceId);
	public Set<String> getInvalidDevices();
}
