package us.pojo.weathernotifier.model;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;

public class RuleTest {
	private static final String JSON = "{\"uuid\":\"blah\",\"enabled\":true,\"version\":\"1.0\",\"subrules\":[{\"message\":\"This is a message\",\"type\":\"MessageSubRule\"},{\"name\":\"Aurora, IL\",\"locId\":\"123456\",\"type\":\"LocationSubRule\"},{\"isFarenheit\":true,\"value\":70,\"op\":\">\",\"type\":\"TemperatureSubRule\"},{\"isFarenheit\":true,\"value\":30,\"forecastTime\":3,\"op\":\"<\",\"type\":\"ForecastTempSubRule\"},{\"conditions\":[\"snow\"],\"type\":\"ConditionSubRule\"},{\"forecastTime\":5,\"conditions\":[\"lightning\"],\"type\":\"ForecastConditionSubRule\"},{\"value\":20,\"units\":\"MPH\",\"op\":\">=\",\"type\":\"WindSpeedSubRule\"},{\"value\":50,\"op\":\"<\",\"type\":\"HumiditySubRule\"},{\"timeRange\":{\"min\":830,\"max\":1400},\"op\":\"between\",\"type\":\"TimeSubRule\"}]}";
	
	@Test
	public void shouldDeserializeModel() throws Exception {
		ObjectMapper target = new ObjectMapper();
		JsonParser p = target.getFactory().createParser(JSON);
		Rule r = p.readValueAs(Rule.class);
		assertEquals("subrules size is wrong",r.getSubrules().size(), 9);
		assertTrue(r.isEnabled());
		assertEquals("1.0", r.getVersion());
		assertEquals("blah", r.getUuid());
		System.out.println(r.toString());
	}
}
