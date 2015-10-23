package us.pojo.tempteller.dao;

import java.util.List;
import java.util.Set;

import us.pojo.tempteller.model.SubRequest;
import us.pojo.tempteller.model.WeatherData;

public interface SubDAO {
	public boolean save(SubRequest req);
	public void delete(SubRequest req);
	public Set<String> getUniqueLocIds();
	public List<SubRequest> getSubscribers(WeatherData data);
	public void update(SubRequest subRequest);
	public void deleteInvalidDevices(Set<String> invalidDevices);
}
