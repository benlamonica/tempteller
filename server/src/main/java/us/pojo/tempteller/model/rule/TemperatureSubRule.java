package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class TemperatureSubRule extends SingleValueSubRule {
	private Boolean isFarenheit;

	public Boolean getIsFarenheit() {
		return isFarenheit;
	}

	public void setIsFarenheit(Boolean isFarenheit) {
		this.isFarenheit = isFarenheit;
	}

	@Override
	public String toString() {
		return "TemperatureSubRule [isFarenheit=" + isFarenheit
				+ ", getValue()=" + getValue() + ", getOp()=" + getOp() + "]";
	}

	@JsonIgnore
	public double getValueInFarenheit() {
		if (isFarenheit) {
			return getValue();
		} else {
			return getValue() * (9/5) + 32;
		}
	}
	
	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		return compare(getOp(), data.getTemperature(), getValueInFarenheit());
	}
}
