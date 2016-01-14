package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

public class LocationSubRule extends SubRule {
	private String locId;
	private String name;
	private String lat;
	private String lng;

	public String getLat() {
		return lat;
	}

	public String getLng() {
		return lng;
	}

	public String getLocId() {
		return locId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((locId == null) ? 0 : locId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		LocationSubRule other = (LocationSubRule) obj;
		if (locId == null) {
			if (other.locId != null)
				return false;
		} else if (!locId.equals(other.locId))
			return false;
		return true;
	}

	public String getName() {
		return name;
	}

	public void setLat(String lat) {
		this.lat = lat;
	}

	public void setLng(String lng) {
		this.lng = lng;
	}

	public void setLocId(String locId) {
		this.locId = locId;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public String toString() {
		return "LocationSubRule [locId=" + locId + ", name=" + name + ", lat=" + lat + ", lng=" + lng + "]";
	}

	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		// location rules don't actually evaluate, since they are a modifier for other rules
		return true;
	}

	public static LocationSubRule cast(SubRule r) {
		return (LocationSubRule) r;
	}
}
