package us.pojo.tempteller.service.weather;

import us.pojo.tempteller.model.weather.WeatherData;

public class OfflineWeatherService implements WeatherService {

	public WeatherData getWeather(String woeid) {
		return new WeatherData(woeid, 68d, 42d);
	}

}
