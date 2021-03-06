package us.pojo.tempteller.model.rule;

import static us.pojo.tempteller.util.ForecastTimeUtil.getForecastTimeAsDate;

import java.util.Date;
import java.util.TimeZone;

import org.apache.commons.lang3.tuple.Pair;

public class ForecastTempSubRule extends TemperatureSubRule {
	private String forecastTime;

	public String getForecastTime() {
		return forecastTime;
	}

	public void setForecastTime(String forecastTime) {
		this.forecastTime = forecastTime;
	}

	@Override
	public String toString() {
		return "ForecastTempSubRule [forecastTime=" + forecastTime
				+ ", getIsFarenheit()=" + getIsFarenheit() + ", getValue()="
				+ getValue() + ", getOp()=" + getOp() + "]";
	}
	
	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		Pair<Double, Double> tempRange = data.getTemperatureAt(getForecastTimeAsDate(forecastTime, tz));
		if (tempRange != null) {
			return compare(getOp(), tempRange.getLeft(), getValueInFarenheit()) || compare(getOp(), tempRange.getRight(), getValueInFarenheit());
		} else {
			return false;
		}
	}

	
}
