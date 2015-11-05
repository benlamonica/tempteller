package us.pojo.tempteller.service.weather;

import us.pojo.tempteller.model.weather.WeatherData;

public interface WeatherService {

	public WeatherData getWeather(String woeid);
}
