package us.pojo.tempteller.model;

import java.io.Serializable;

public class WeatherData implements Serializable {
	private static final long serialVersionUID = 1L;

	private String woeid;
	
	private Double temperature;
	
	private Double humidity;

	public WeatherData(String WOEID, Double temp, Double humidity) {
		this.woeid = WOEID;
		this.temperature = temp;
		this.humidity = humidity;
	}
	
	public String getWOEID() {
		return woeid;
	}
	
	public Double getTemperature() {
		return temperature;
	}

	public Double getHumidity() {
		return humidity;
	}

	@Override
	public String toString() {
		return "WeatherData [woeid=" + woeid + ", temperature=" + temperature
				+ ", humidity=" + humidity + "]";
	}
}
