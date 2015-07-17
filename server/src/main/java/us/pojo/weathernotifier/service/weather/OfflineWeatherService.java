package us.pojo.weathernotifier.service.weather;

import us.pojo.weathernotifier.model.WOEID;
import us.pojo.weathernotifier.model.WeatherData;

public class OfflineWeatherService implements WeatherService {

	public WOEID getWOEID(String query) {
		return new WOEID(query);
	}

	public WeatherData getWeather(String woeid) {
		return new WeatherData(woeid, 68d, 42d);
	}

}
