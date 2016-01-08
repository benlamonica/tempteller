package us.pojo.tempteller.service.weather;

import us.pojo.tempteller.model.rule.WeatherData;

public interface WeatherService {
	public WeatherData getWeather(String locId, String lat, String lng, long startTime, long endTime);
}
