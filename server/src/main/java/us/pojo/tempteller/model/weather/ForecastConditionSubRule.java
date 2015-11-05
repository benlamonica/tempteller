package us.pojo.tempteller.model.weather;

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
	
}
