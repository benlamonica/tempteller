package us.pojo.weathernotifier.model;

public class LocationSubRule extends SubRule {
	private String name;
	private String locId;

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLocId() {
		return locId;
	}

	public void setLocId(String locId) {
		this.locId = locId;
	}

	@Override
	public String toString() {
		return "LocationSubRule [name=" + name + ", locId=" + locId + "]";
	}

}
