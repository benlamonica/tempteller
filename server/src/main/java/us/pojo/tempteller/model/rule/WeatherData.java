package us.pojo.tempteller.model.rule;

import java.io.Serializable;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;

public class WeatherData implements Serializable {
	private static final long serialVersionUID = 1L;

	private static class ForecastData {
		public ForecastData(double tempMin, double tempMax, String condition) {
			this.temperature = new ImmutablePair<Double,Double>(tempMin, tempMax);
			this.condition = condition;
		}
		public Pair<Double,Double> temperature;
		public String condition;
	}
	
	private String locId;

	double temperature;
	double humidity;
	double windspeed;
	int time;
	String condition;
	TreeMap<Long, ForecastData> forecast = new TreeMap<>();
	
	@SuppressWarnings("unchecked")
	private <T> T getValue(Map<String, Object> json, Class<T> returnType, String ... path) {
		for (int i = 0; i < path.length - 1; i++) {
			if (json != null) {
				json = (Map<String, Object>) json.get(path[i]);
			}
		}
		
		String key = path[path.length-1];
		if (json != null && json.containsKey(key)) {
			Object val = json.get(key);
			if (val.getClass() != returnType) {
				String s = String.valueOf(val);
				if (returnType == Double.class) {
					val = Double.valueOf(s);
				} else if (returnType == Float.class) {
					val = Float.valueOf(s);
				} else if (returnType == Integer.class) {
					val = Integer.valueOf(s);
				} else if (returnType == Long.class) {
					val = Long.valueOf(s);
				} else if (returnType == String.class) {
					val = s;
				}
			}
			return (T) val;
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
		this.time = getValue(json, Integer.class, "currently", "time");
		addForecast(getValue(json, List.class, "daily", "data"));
		addForecast(getValue(json, List.class, "hourly", "data"));
		forecast.put((long)time, new ForecastData(temperature, temperature, condition));
	}
	
	public void addForecast(List<Map<String, Object>> forecastData) {
		for (Map<String,Object> forecastDatum : forecastData) {
			int time = getValue(forecastDatum, Integer.class, "time");
			Double tempMin = getValue(forecastDatum, Double.class, "temperature");
			Double tempMax = null;
			if (tempMin == null) { // handle daily forecasts, which don't specify the exact temp.
				tempMin = getValue(forecastDatum, Double.class, "temperatureMin");
				tempMax = getValue(forecastDatum, Double.class, "temperatureMax");
			} else {
				tempMax = tempMin;
			}
			String condition = getValue(forecastDatum, String.class, "condition");
			forecast.put((long)time, new ForecastData(tempMin, tempMax, condition));
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

	public Pair<Double,Double> getTemperatureAt(Date forecastTime) {
		SortedMap<Long, ForecastData> forecastData = forecast.subMap(forecastTime.getTime(), forecastTime.getTime() + 60 * 60 * 1000);
		if (!forecastData.isEmpty()) {
			return forecastData.values().iterator().next().temperature;
		} else {
			return null;
		}
	}
}
