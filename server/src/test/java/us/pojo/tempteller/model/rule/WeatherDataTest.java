package us.pojo.tempteller.model.rule;

import static org.junit.Assert.assertEquals;

import java.nio.charset.Charset;
import java.util.Map;

import org.junit.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

public class WeatherDataTest {

	private ObjectMapper mapper = new ObjectMapper();
	
	@SuppressWarnings("unchecked")
	@Test
	public void shouldParseWeahterDataFromJson() throws Exception {
		ClassPathResource res = new ClassPathResource("weather-data.json");
		String json = StreamUtils.copyToString(res.getInputStream(), Charset.forName("utf8"));
		Map<String,Object> data = mapper.readValue(json, Map.class);
		WeatherData target = new WeatherData("loc", data);
		assertEquals(target.getTemperature(), 4.9, 0.01);

	}
}
