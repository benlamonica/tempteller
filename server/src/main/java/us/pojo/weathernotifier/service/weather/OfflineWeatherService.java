package us.pojo.weathernotifier.service.weather;

import us.pojo.weathernotifier.model.WeatherData;

public class OfflineWeatherService implements WeatherService {

	public WeatherData getWeather(String woeid) {
		return new WeatherData(woeid, 68d, 42d);
	}

}
