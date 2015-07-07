package us.pojo.weathernotifier.model;

import java.io.Serializable;

public class SubRequest implements Serializable {
	private static final long serialVersionUID = 1L;
	private String name;
	private int subId;
	private String noteEnter;
	private String noteLeave;
	private String woeId;
	private String deviceId;
	private boolean notifyWhenTempEntersRange = false;
	private boolean notifyWhenTempLeavesRange = false;
	private boolean farenheitToBeUsed = true;
	private boolean notifyOnlyWhenTempAndHumidityMatch = false;
	private boolean inRangeNotified = false;
	private Integer minTemp;
	private Integer maxTemp;
	private Integer minHumidity;
	private Integer maxHumidity;
	
	public int getSubId() {
		return subId;
	}

	public void setSubId(int subId) {
		this.subId = subId;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		SubRequest other = (SubRequest) obj;
		if (deviceId == null) {
			if (other.deviceId != null)
				return false;
		} else if (!deviceId.equals(other.deviceId))
			return false;
		if (farenheitToBeUsed != other.farenheitToBeUsed)
			return false;
		if (inRangeNotified != other.inRangeNotified)
			return false;
		if (maxHumidity == null) {
			if (other.maxHumidity != null)
				return false;
		} else if (!maxHumidity.equals(other.maxHumidity))
			return false;
		if (maxTemp == null) {
			if (other.maxTemp != null)
				return false;
		} else if (!maxTemp.equals(other.maxTemp))
			return false;
		if (minHumidity == null) {
			if (other.minHumidity != null)
				return false;
		} else if (!minHumidity.equals(other.minHumidity))
			return false;
		if (minTemp == null) {
			if (other.minTemp != null)
				return false;
		} else if (!minTemp.equals(other.minTemp))
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (noteEnter == null) {
			if (other.noteEnter != null)
				return false;
		} else if (!noteEnter.equals(other.noteEnter))
			return false;
		if (noteLeave == null) {
			if (other.noteLeave != null)
				return false;
		} else if (!noteLeave.equals(other.noteLeave))
			return false;
		if (notifyOnlyWhenTempAndHumidityMatch != other.notifyOnlyWhenTempAndHumidityMatch)
			return false;
		if (notifyWhenTempEntersRange != other.notifyWhenTempEntersRange)
			return false;
		if (notifyWhenTempLeavesRange != other.notifyWhenTempLeavesRange)
			return false;
		if (subId != other.subId)
			return false;
		if (woeId == null) {
			if (other.woeId != null)
				return false;
		} else if (!woeId.equals(other.woeId))
			return false;
		return true;
	}

	public String getDeviceId() {
		return deviceId;
	}

	public Integer getMaxHumidity() {
		return maxHumidity;
	}

	public Integer getMaxTemp() {
		return maxTemp;
	}

	public Integer getMinHumidity() {
		return minHumidity;
	}

	public Integer getMinTemp() {
		return minTemp;
	}

	public String getName() {
		return name;
	}

	public String getNoteEnter() {
		return noteEnter;
	}

	public String getNoteLeave() {
		return noteLeave;
	}

	public boolean getNotifyOnlyWhenTempAndHumidityMatch() {
		return notifyOnlyWhenTempAndHumidityMatch;
	}

	public boolean getNotifyWhenTempEntersRange() {
		return notifyWhenTempEntersRange;
	}

	public boolean getNotifyWhenTempLeavesRange() {
		return notifyWhenTempLeavesRange;
	}

	public String getWoeId() {
		return woeId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((deviceId == null) ? 0 : deviceId.hashCode());
		result = prime * result + (farenheitToBeUsed ? 1231 : 1237);
		result = prime * result + (inRangeNotified ? 1231 : 1237);
		result = prime * result
				+ ((maxHumidity == null) ? 0 : maxHumidity.hashCode());
		result = prime * result + ((maxTemp == null) ? 0 : maxTemp.hashCode());
		result = prime * result
				+ ((minHumidity == null) ? 0 : minHumidity.hashCode());
		result = prime * result + ((minTemp == null) ? 0 : minTemp.hashCode());
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result
				+ ((noteEnter == null) ? 0 : noteEnter.hashCode());
		result = prime * result
				+ ((noteLeave == null) ? 0 : noteLeave.hashCode());
		result = prime * result
				+ (notifyOnlyWhenTempAndHumidityMatch ? 1231 : 1237);
		result = prime * result + (notifyWhenTempEntersRange ? 1231 : 1237);
		result = prime * result + (notifyWhenTempLeavesRange ? 1231 : 1237);
		result = prime * result + subId;
		result = prime * result + ((woeId == null) ? 0 : woeId.hashCode());
		return result;
	}

	public boolean isEnteringRange(WeatherData data) {
		if (!notifyWhenTempEntersRange || inRangeNotified) {
			return false;
		}
		
		if (data.getTemperature() >= minTemp && data.getTemperature() <= maxTemp) {
			if (notifyOnlyWhenTempAndHumidityMatch) {
				if (data.getHumidity() < minHumidity || data.getHumidity() > maxHumidity) {
					return false;
				}
			}
			
			return true;
		}
		
		return false;
	}

	public boolean isFarenheitToBeUsed() {
		return farenheitToBeUsed;
	}

	public boolean isInRangeNotified() {
		return inRangeNotified;
	}

	public boolean isLeavingRange(WeatherData data) {
		if (!notifyWhenTempLeavesRange || !inRangeNotified) {
			return false;
		}
		
		if (notifyOnlyWhenTempAndHumidityMatch) {
			if (data.getHumidity() < minHumidity || data.getHumidity() > maxHumidity) {
				return true;
			}
		}

		if (data.getTemperature() < minTemp || data.getTemperature() > maxTemp) {
			return true;
		}

		return false;
	}

	public boolean isSubscribed() {
		return notifyWhenTempEntersRange || notifyWhenTempLeavesRange;
	}

	public void setDeviceId(String subscriberId) {
		this.deviceId = subscriberId;
	}

	public void setFarenheitToBeUsed(boolean useFarenheit) {
		this.farenheitToBeUsed = useFarenheit;
	}

	public void setInRangeNotified(boolean notified) {
		inRangeNotified = notified;
	}

	public void setMaxHumidity(Integer maxHumidity) {
		this.maxHumidity = maxHumidity;
	}

	public void setMaxTemp(Integer maxTemp) {
		this.maxTemp = maxTemp;
	}

	public void setMinHumidity(Integer minHumidity) {
		this.minHumidity = minHumidity;
	}

	public void setMinTemp(Integer minTemp) {
		this.minTemp = minTemp;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public void setNoteEnter(String noteEnter) {
		this.noteEnter = noteEnter;
	}

	public void setNoteLeave(String noteLeave) {
		this.noteLeave = noteLeave;
	}

	public void setNotifyOnlyWhenTempAndHumidityMatch(
			boolean notifyOnlyWhenTempAndHumidityMatch) {
		this.notifyOnlyWhenTempAndHumidityMatch = notifyOnlyWhenTempAndHumidityMatch;
	}

	
	public void setNotifyWhenTempEntersRange(boolean notifyWhenTempEntersRange) {
		this.notifyWhenTempEntersRange = notifyWhenTempEntersRange;
	}
	
	public void setNotifyWhenTempLeavesRange(boolean notifyWhenTempLeavesRange) {
		this.notifyWhenTempLeavesRange = notifyWhenTempLeavesRange;
	}
	
	public void setWoeId(String woeId) {
		this.woeId = woeId;
	}
	
	@Override
	public String toString() {
		return "SubRequest [name=" + name + ", subId=" + subId + ", noteEnter="
				+ noteEnter + ", noteLeave=" + noteLeave + ", woeId=" + woeId
				+ ", deviceId=" + deviceId + ", notifyWhenTempEntersRange="
				+ notifyWhenTempEntersRange + ", notifyWhenTempLeavesRange="
				+ notifyWhenTempLeavesRange + ", farenheitToBeUsed="
				+ farenheitToBeUsed + ", notifyOnlyWhenTempAndHumidityMatch="
				+ notifyOnlyWhenTempAndHumidityMatch + ", inRangeNotified="
				+ inRangeNotified + ", minTemp=" + minTemp + ", maxTemp="
				+ maxTemp + ", minHumidity=" + minHumidity + ", maxHumidity="
				+ maxHumidity + "]";
	}

}
