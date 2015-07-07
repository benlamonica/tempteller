package us.pojo.weathernotifier.service;

import us.pojo.weathernotifier.model.WOEID;
import us.pojo.weathernotifier.model.WeatherData;

public interface WeatherService {

	public WOEID getWOEID(String query);

	public WeatherData getWeather(String woeid);
}
