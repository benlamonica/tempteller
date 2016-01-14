package us.pojo.tempteller.service.weather;

import java.io.IOException;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import us.pojo.tempteller.model.rule.WeatherData;

@Service(value="WeatherService")
public class ForecastIOWeatherService implements WeatherService {

	private static final Logger log = LoggerFactory.getLogger(ForecastIOWeatherService.class);
	
	@Autowired(required=true)
	private RestTemplate http;
	
	@Autowired(required=true)
	private ObjectMapper mapper;
	
	@Value(value="${forecast.io.url}")
	private String forecastIoUrl;

	@Override
	public WeatherData getWeather(String locId, String lat, String lng, long startTime, long endTime) {
		long time = System.currentTimeMillis();
		log.info("Retrieving weather for {}/{},{}", locId, lat, lng);
		String json = http.getForObject("{forecast.io.url}/{lat},{lng}", String.class, forecastIoUrl, lat, lng);
		log.info("Retrieved weather for {}/{},{} in {} ms", locId, lat, lng, (System.currentTimeMillis() - time));
		log.debug(json);
		try {
			@SuppressWarnings("unchecked")
			Map<String,Object> data = mapper.readValue(json, Map.class);
			return new WeatherData(locId, data);
		} catch (RestClientException | IOException e) {
			log.warn("Unable to parse json from {}/{},{}\n{}", forecastIoUrl, lat, lng, json, e);
		}
		return null;
	}

}
