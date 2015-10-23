package us.pojo.tempteller.service.weather;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.client.RestTemplate;

import us.pojo.tempteller.model.WeatherData;
import us.pojo.tempteller.transformer.JSONToWOEIDTransformer;
import us.pojo.tempteller.transformer.RSStoWeatherDataTransformer;

public class YahooWeatherService implements WeatherService {

	private static final Logger log = LoggerFactory.getLogger(YahooWeatherService.class);
	
	@Autowired
	private RSStoWeatherDataTransformer weatherTransformer;
	
	@Autowired
	private JSONToWOEIDTransformer woeidTransformer;
	
	@Autowired
	private RestTemplate rest;
	
	public WeatherData getWeather(String woeid) {
		long start = System.currentTimeMillis();
		try {
			String xml = rest.getForObject("https://weather.yahooapis.com/forecastrss?w={1}", String.class, woeid);
			return weatherTransformer.transform(woeid, xml);
		} finally {
			log.info("Requesting weather for locId {} took {} ms", (System.currentTimeMillis() - start));
		}
	}
}