package us.pojo.weathernotifier.model;

public class ForecastConditionSubRule extends ConditionSubRule {
	private Integer forecastTime;

	public Integer getForecastTime() {
		return forecastTime;
	}

	public void setForecastTime(Integer forecastTime) {
		this.forecastTime = forecastTime;
	}

	@Override
	public String toString() {
		return "ForecastConditionSubRule [forecastTime=" + forecastTime
				+ ", getConditions()=" + getConditions() + "]";
	}
	
}
