package us.pojo.weathernotifier.service.weather;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.client.RestTemplate;

import us.pojo.weathernotifier.model.WOEID;
import us.pojo.weathernotifier.model.WeatherData;
import us.pojo.weathernotifier.transformer.JSONToWOEIDTransformer;
import us.pojo.weathernotifier.transformer.RSStoWeatherDataTransformer;

public class YahooWeatherService implements WeatherService {

	private static final Logger log = LoggerFactory.getLogger(YahooWeatherService.class);
	
	@Autowired
	private RSStoWeatherDataTransformer weatherTransformer;
	
	@Autowired
	private JSONToWOEIDTransformer woeidTransformer;
	
	@Autowired
	private RestTemplate rest;
	
	public WOEID getWOEID(String query) {
		String json = rest.getForObject("https://query.yahooapis.com/v1/public/yql?q=select * from geo.placefinder where text=&format=json)", String.class, query);
		log.debug("JSON retrieved is {}", json);
		return woeidTransformer.transform(json);
	}

	public WeatherData getWeather(String woeid) {
		String xml = rest.getForObject("https://weather.yahooapis.com/forecastrss?w={1}", String.class, woeid);
		return weatherTransformer.transform(woeid, xml);
	}
}