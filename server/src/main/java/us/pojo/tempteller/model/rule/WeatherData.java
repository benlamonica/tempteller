package us.pojo.tempteller.model.rule;

import java.io.Serializable;
import java.util.Date;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

public class WeatherData implements Serializable {
	private static final long serialVersionUID = 1L;

	private static class ForecastData {
		public ForecastData(double temperature, String condition) {
			this.temperature = temperature;
			this.condition = condition;
		}
		public double temperature;
		public String condition;
	}
	
	private String locId;

	double temperature;
	double humidity;
	double windspeed;
	long time;
	String condition;
	TreeMap<Long, ForecastData> forecast = new TreeMap<>();
	
	@SuppressWarnings("unchecked")
	private <T> T getValue(Map<String, Object> json, Class<T> returnType, String ... path) {
		for (int i = 0; i < path.length - 2; i++) {
			if (json != null) {
				json = (Map<String, Object>) json.get(path[i]);
			}
		}
		
		String key = path[path.length-1];
		if (json != null && json.containsKey(key)) {
			return (T) json.get(key);
		} else {
			return null;
		}
	}
	
	@SuppressWarnings("unchecked")
	public WeatherData(String locId, Map<String, Object> json) {
		this.locId = locId;
		this.temperature = getValue(json, Double.class, "currently", "temperature");
		this.humidity = getValue(json, Double.class, "currently", "humidity");
		this.windspeed = getValue(json, Double.class, "currently", "windSpeed");
		this.condition = getValue(json, String.class, "currently", "icon");
		this.time = getValue(json, Long.class, "currently", "time");
		addForecast(getValue(json, Map[].class, "daily", "data"));
		addForecast(getValue(json, Map[].class, "hourly", "data"));
		forecast.put(time, new ForecastData(temperature,condition));
	}
	
	public void addForecast(Map<String, Object>[] forecastData) {
		for (Map<String,Object> forecastDatum : forecastData) {
			long time = getValue(forecastDatum, Long.class, "time");
			double temperature = getValue(forecastDatum, Double.class, "temperature");
			String condition = getValue(forecastDatum, String.class, "condition");
			forecast.put(time, new ForecastData(temperature, condition));
		}
	}
	public String getLocId() {
		return locId;
	}
	
	public Double getTemperature() {
		return temperature;
	}

	public Double getHumidity() {
		return humidity;
	}

	@Override
	public String toString() {
		return "WeatherData [locId=" + locId + ", temperature=" + temperature + ", humidity=" + humidity
				+ ", windspeed=" + windspeed + ", time=" + time + ", condition=" + condition + ", forecastCount=" + forecast.size()
				+ "]";
	}

	public Double getWindSpeed() {
		return windspeed;
	}

	public String getCondition() {
		return condition;
	}

	public String getConditionAt(Date forecastTime) {
		SortedMap<Long, ForecastData> forecastData = forecast.subMap(forecastTime.getTime(), forecastTime.getTime() + 60 * 60 * 1000);
		if (!forecastData.isEmpty()) {
			return forecastData.values().iterator().next().condition;
		} else {
			return null;
		}
	}

	public Double getTemperatureAt(Date forecastTime) {
		SortedMap<Long, ForecastData> forecastData = forecast.subMap(forecastTime.getTime(), forecastTime.getTime() + 60 * 60 * 1000);
		if (!forecastData.isEmpty()) {
			return forecastData.values().iterator().next().temperature;
		} else {
			return null;
		}
	}
}
