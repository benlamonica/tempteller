package us.pojo.tempteller.service;

import us.pojo.tempteller.model.SubRequest;

public interface SubManager {

	public boolean subscribe(SubRequest req);

	public void unsubscribe(String deviceId);
}
