package us.pojo.weathernotifier.dao;

import java.util.List;
import java.util.Set;

import us.pojo.weathernotifier.model.SubRequest;
import us.pojo.weathernotifier.model.WeatherData;

public interface SubDAO {
	public boolean save(SubRequest req);
	public void delete(SubRequest req);
	public Set<String> getUniqueLocIds();
	public List<SubRequest> getSubscribers(WeatherData data);
	public void update(SubRequest subRequest);
	public void deleteInvalidDevices(Set<String> invalidDevices);
}
