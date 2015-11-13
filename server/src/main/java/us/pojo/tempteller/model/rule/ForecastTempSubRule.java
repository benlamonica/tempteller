package us.pojo.tempteller.model.rule;

import static us.pojo.tempteller.util.ForecastTimeUtil.getForecastTimeAsDate;

import java.util.Date;
import java.util.TimeZone;

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
		return compare(getOp(), data.getTemperatureAt(getForecastTimeAsDate(forecastTime, tz)), getValueInFarenheit());
	}

	
}
