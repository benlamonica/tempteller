package us.pojo.tempteller.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;

import us.pojo.tempteller.model.weather.Rule;

public class RuleTest {
	private static final String JSON = "{\"enabled\":true,\"subrules\":[{\"type\":\"MessageSubRule\",\"message\":\"This is a message\"},{\"locId\":\"11_12784194\",\"lat\":\"37.477141\",\"lng\":\"-122.299083\",\"type\":\"LocationSubRule\",\"name\":\"Aurora, IL\"},{\"op\":\"at\",\"type\":\"TimeSubRule\",\"timeRange\":{\"max\":\"12:00 PM\",\"min\":\"12:00 PM\"}},{\"op\":\">\",\"isFarenheit\":true,\"type\":\"TemperatureSubRule\",\"value\":70},{\"op\":\"<\",\"isFarenheit\":true,\"forecastTime\":\"Today @ 3:00 AM\",\"type\":\"ForecastTempSubRule\",\"value\":30},{\"op\":\"is\",\"type\":\"ConditionSubRule\",\"conditions\":[\"snowy\"]},{\"op\":\"is not\",\"forecastTime\":\"5:00 AM\",\"type\":\"ForecastConditionSubRule\",\"conditions\":[\"lightning\"]},{\"op\":\">=\",\"units\":\"MPH\",\"type\":\"WindSpeedSubRule\",\"value\":20},{\"op\":\"<\",\"type\":\"HumiditySubRule\",\"value\":50},{\"op\":\"between\",\"type\":\"TimeSubRule\",\"timeRange\":{\"max\":\"2:00 PM\",\"min\":\"8:30 AM\"}}],\"version\":\"1.0\",\"uuid\":\"blah\"}";
	@Test
	public void shouldDeserializeModel() throws Exception {
		ObjectMapper target = new ObjectMapper();
		JsonParser p = target.getFactory().createParser(JSON);
		Rule r = p.readValueAs(Rule.class);
		assertEquals("subrules size is wrong",10, r.getSubrules().size());
		assertTrue(r.isEnabled());
		assertEquals("1.0", r.getVersion());
		assertEquals("blah", r.getUuid());
		System.out.println(r.toString());
	}
}
