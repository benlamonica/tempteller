package us.pojo.tempteller.model;

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
	
	
}
