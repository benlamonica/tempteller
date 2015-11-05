package us.pojo.tempteller.model.weather;

import java.util.List;

public class Rule {
	private Boolean enabled;
	private List<SubRule> subrules;
	private String uuid;
	private String version;

	public String getVersion() {
		return version;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	public Boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(Boolean enabled) {
		this.enabled = enabled;
	}

	public List<SubRule> getSubrules() {
		return subrules;
	}

	public void setSubrules(List<SubRule> subrules) {
		this.subrules = subrules;
	}

	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}

	@Override
	public String toString() {
		return "Rule [enabled=" + enabled + ", subrules=" + subrules
				+ ", uuid=" + uuid + ", version=" + version + "]";
	}

}
