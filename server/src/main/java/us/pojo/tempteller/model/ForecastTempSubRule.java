package us.pojo.tempteller.model;

public class ForecastTempSubRule extends TemperatureSubRule {
	private Integer forecastTime;

	public Integer getForecastTime() {
		return forecastTime;
	}

	public void setForecastTime(Integer forecastTime) {
		this.forecastTime = forecastTime;
	}

	@Override
	public String toString() {
		return "ForecastTempSubRule [forecastTime=" + forecastTime
				+ ", getIsFarenheit()=" + getIsFarenheit() + ", getValue()="
				+ getValue() + ", getOp()=" + getOp() + "]";
	}
	
	
}
