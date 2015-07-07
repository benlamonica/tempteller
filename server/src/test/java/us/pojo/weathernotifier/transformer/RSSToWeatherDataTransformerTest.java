package us.pojo.weathernotifier.transformer;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.io.InputStreamReader;

import org.junit.Test;
import org.springframework.util.FileCopyUtils;

import us.pojo.weathernotifier.model.WeatherData;

public class RSSToWeatherDataTransformerTest {

	@Test
	public void shouldParseRSSFileAndExtractWeatherInformation() throws IOException {
		String xml = FileCopyUtils.copyToString(new InputStreamReader(getClass().getResourceAsStream("/rss-weather-example.xml")));
		RSStoWeatherDataTransformer target = new RSStoWeatherDataTransformer();
		WeatherData result = target.transform("123456", xml);
		assertEquals(result.toString(),"WeatherData [woeid=123456, temperature=69.0, humidity=68.0]");
	}
	
	@Test
	public void shouldReturnNullIfUnableToParse() throws IOException {
		String xml = FileCopyUtils.copyToString(new InputStreamReader(getClass().getResourceAsStream("/rss-weather-example.xml")));
		RSStoWeatherDataTransformer target = new RSStoWeatherDataTransformer();
		WeatherData result = target.transform("123456", "<"+xml);
		assertEquals(result.toString(),"WeatherData [woeid=123456, temperature=null, humidity=null]");
	}

}
