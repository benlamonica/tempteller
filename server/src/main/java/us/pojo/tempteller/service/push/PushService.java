package us.pojo.tempteller.service.push;

import java.util.Set;

public interface PushService {
	boolean push(String msg, String deviceId);
	public Set<String> getInvalidDevices();
}
