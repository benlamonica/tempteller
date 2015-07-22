package us.pojo.weathernotifier.service;

import us.pojo.weathernotifier.model.SubRequest;

public interface SubManager {

	public boolean subscribe(SubRequest req);

	public void unsubscribe(String deviceId);
}
