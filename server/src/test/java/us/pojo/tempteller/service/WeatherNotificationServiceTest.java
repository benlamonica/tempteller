package us.pojo.tempteller.service;

import static org.easymock.EasyMock.anyLong;
import static org.easymock.EasyMock.anyObject;
import static org.easymock.EasyMock.eq;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;

import java.sql.Date;
import java.util.Collections;
import java.util.Set;

import org.easymock.EasyMock;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import us.pojo.tempteller.model.rule.LocationSubRule;
import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.WeatherData;
import us.pojo.tempteller.service.notify.WeatherNotificationService;
import us.pojo.tempteller.service.push.PushService;
import us.pojo.tempteller.service.rule.RuleService;
import us.pojo.tempteller.service.weather.WeatherService;

public class WeatherNotificationServiceTest {

	private WeatherNotificationService target;
	
	private PushService mockPush = EasyMock.createMock(PushService.class);
	private WeatherService mockWeather = EasyMock.createMock(WeatherService.class);
	private RuleService mockRules = EasyMock.createMock(RuleService.class);
	private NotifiableRule mockRule = EasyMock.createMock(NotifiableRule.class);
	private WeatherData mockData = EasyMock.createMock(WeatherData.class);
	private LocationSubRule loc;
	@Before
	public void setup() {
		target = new WeatherNotificationService();
		target.setPushService(mockPush);
		target.setWeatherService(mockWeather);
		target.setRuleService(mockRules);
		loc = new LocationSubRule();
		loc.setLocId("locId");
		loc.setLat("-45");
		loc.setLng("24");
		loc.setName("Sunnydale, CA");
		loc.setType("LocationSubRule");
	}
	
	@After
	public void verifyMocks() {
		verify(mockPush, mockWeather, mockRules, mockRule, mockData);
	}
	
	@Test
	public void shouldGetActiveRulesRetrieveWeatherAndSendNotifications() {
		expect(mockRules.getActiveRules()).andReturn(Collections.singletonList(mockRule));
		expect(mockRule.getLocations()).andReturn(Collections.singleton(loc));
		expect(mockWeather.getWeather(eq("locId"), eq("-45"), eq("24"), anyLong(), anyLong())).andReturn(mockData);
		expect(mockRule.ruleMatches(anyObject(Date.class), anyObject())).andReturn(true);
		expect(mockRule.getMessage()).andReturn("A message!");
		expect(mockRule.getDecodedPushToken()).andReturn("deviceId");
		expect(mockPush.push("A message!", "deviceId")).andReturn(true);
		expect(mockPush.getInvalidDevices()).andReturn(Collections.emptySet());
		replay(mockPush,mockRules,mockWeather,mockRule,mockData);
		target.runOnce();
	}
	
	@Test
	public void shouldInvalidateRulesAttachedToInvalidDevices() {
		expect(mockRules.getActiveRules()).andReturn(Collections.emptyList());
		Set<String> invalidPushTokens = Collections.singleton("InvalidPushToken");
		expect(mockPush.getInvalidDevices()).andReturn(invalidPushTokens);
		mockRules.invalidateDevices(invalidPushTokens);
		replay(mockPush,mockRules,mockWeather,mockRule,mockData);
		target.runOnce();
	}

}
