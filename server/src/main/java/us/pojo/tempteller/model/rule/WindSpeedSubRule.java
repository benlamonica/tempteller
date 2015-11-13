package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class WindSpeedSubRule extends SingleValueSubRule {
	private String units;

	public String getUnits() {
		return units;
	}

	public void setUnits(String units) {
		this.units = units;
	}

	@JsonIgnore
	private double getValueInMPH() {
		if ("kph".equalsIgnoreCase(units)) {
			return getValue() / 1.609344;
		} else {
			return getValue();
		}
	}
	
	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		return compare(getOp(), data.getWindSpeed(), getValueInMPH());
	}

	@Override
	public String toString() {
		return "WindSpeedSubRule [units=" + units + ", getValue()="
				+ getValue() + ", getOp()=" + getOp() + "]";
	}

}
