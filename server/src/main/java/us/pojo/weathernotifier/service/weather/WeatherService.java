package us.pojo.weathernotifier.service.weather;

import us.pojo.weathernotifier.model.WeatherData;

public interface WeatherService {

	public WeatherData getWeather(String woeid);
}
