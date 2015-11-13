package us.pojo.tempteller.model.rule;

import static us.pojo.tempteller.util.ForecastTimeUtil.getForecastTimeAsDate;

import java.util.Date;
import java.util.TimeZone;

public class ForecastConditionSubRule extends ConditionSubRule {
	private String forecastTime;

	public String getForecastTime() {
		return forecastTime;
	}

	public void setForecastTime(String forecastTime) {
		this.forecastTime = forecastTime;
	}

	@Override
	public String toString() {
		return "ForecastConditionSubRule [forecastTime=" + forecastTime
				+ ", getConditions()=" + getConditions() + "]";
	}

	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		return getConditions().contains(data.getConditionAt(getForecastTimeAsDate(forecastTime, tz)));
	}
}
