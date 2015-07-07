package us.pojo.weathernotifier.dao;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import us.pojo.weathernotifier.model.SubRequest;
import us.pojo.weathernotifier.model.WeatherData;

public class SubDAOImpl implements SubDAO {

	private Map<String, SubRequest> subRequests = new HashMap<String, SubRequest>();
	private Set<String> unqWOEIds = new HashSet<String>();
	
	public SubRequest get(String devId) {
		return subRequests.get(devId);
	}
	
	public boolean save(SubRequest req) {
		subRequests.put(req.getDeviceId(), req);
		if (req.getWoeId() != null) {
			unqWOEIds.add(req.getWoeId());
		}
		return true;
	}

	public List<String> getUniqueWOEIDs() {
		return new ArrayList<String>(unqWOEIds);
	}

	public List<SubRequest> getSubscribers(WeatherData data) {
		if (data != null) {
			List<SubRequest> subs = new ArrayList<SubRequest>();
			for (SubRequest req : subRequests.values()) {
				if (data.getWOEID().equals(req.getWoeId())) {
					subs.add(req);
				}
			}
			
			return subs;
		}
		
		return Collections.emptyList();
	}

	public void update(SubRequest subRequest) {
		// nothing to do
	}

	public void delete(SubRequest req) {
		subRequests.remove(req.getDeviceId());
	}

	public void deleteInvalidDevices(Set<String> invalidDevices) {
		for (String devId : invalidDevices) {
			subRequests.remove(devId);
		}
	}

}
