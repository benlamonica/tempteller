package us.pojo.tempteller.service.weather;

import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Map;

import org.springframework.util.StreamUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import us.pojo.tempteller.model.rule.WeatherData;

public class OfflineWeatherService implements WeatherService {

	private ObjectMapper mapper = new ObjectMapper();
	
	private String data;
	private Map<String, Object> json;
	
	@SuppressWarnings("unchecked")
	public OfflineWeatherService() {
		try {
			data = StreamUtils.copyToString(OfflineWeatherService.class.getResourceAsStream("forecast.json"), Charset.forName("utf8"));
			json = mapper.readValue(data, Map.class);
		} catch (IOException e) {
			throw new RuntimeException("Unable to load forecast.json", e);
		}
	}
	
	public WeatherData getWeather(String woeid) {
		return new WeatherData(woeid, json);
	}

}
