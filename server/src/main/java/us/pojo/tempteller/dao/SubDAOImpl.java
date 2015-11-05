package us.pojo.tempteller.dao;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import us.pojo.tempteller.model.weather.LocationSubRule;
import us.pojo.tempteller.model.weather.Rule;
import us.pojo.tempteller.model.weather.SubRequest;
import us.pojo.tempteller.model.weather.SubRule;
import us.pojo.tempteller.model.weather.UserId;
import us.pojo.tempteller.model.weather.WeatherData;

public class SubDAOImpl implements SubDAO {

	private Map<String, SubRequest> subRequests = new HashMap<String, SubRequest>();
	private Map<String, List<SubRequest>> unqLocIds = new HashMap<String, List<SubRequest>>();
	
	public SubRequest get(String devId) {
		return subRequests.get(devId);
	}
	
	public boolean save(SubRequest req) {
		synchronized(subRequests) {
			String devId = req.getUserId().getDeviceId();
			subRequests.put(devId, req);
		}
		
		for (Rule rule : req.getRules()) {
			for (SubRule subrule : rule.getSubrules()) {
				if (subrule instanceof LocationSubRule) {
					synchronized(unqLocIds) {
						String locId = ((LocationSubRule) subrule).getLocId();
						if (!unqLocIds.containsKey(locId)) {
							unqLocIds.put(locId, new ArrayList<SubRequest>());
						}
						unqLocIds.get(locId).add(req);
					}
				}
			}
		}
		return true;
	}

	public Set<String> getUniqueLocIds() {
		return unqLocIds.keySet();
	}

	public List<SubRequest> getSubscribers(WeatherData data) {
		if (data != null) {
			return unqLocIds.get(data.getWOEID());
		}
		
		return Collections.emptyList();
	}

	public void update(SubRequest subRequest) {
		// nothing to do
	}

	public void delete(SubRequest req) {
		synchronized (subRequests) {
			subRequests.remove(req.getUserId().getDeviceId());
		}
	}

	public void deleteInvalidDevices(Set<String> invalidDevices) {
		for (String devId : invalidDevices) {
			subRequests.remove(devId);
		}
	}

}
