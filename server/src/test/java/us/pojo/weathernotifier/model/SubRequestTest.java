package us.pojo.weathernotifier.model;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class SubRequestTest {

	@Test
	public void shouldEnterRangeIfNotNotifiedAndTempWithinRange() {
		WeatherData weather = new WeatherData("12345", 51.0, 0.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(0);
		target.setMaxHumidity(100);
		target.setNotifyWhenTempEntersRange(true);
		assertTrue(target.isEnteringRange(weather));
	}
	
	@Test
	public void shouldNotEnterRangeIfNotifiedAndTempWithinRange() {
		WeatherData weather = new WeatherData("12345", 51.0, 0.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(0);
		target.setMaxHumidity(100);
		target.setInRangeNotified(true);
		target.setNotifyWhenTempEntersRange(true);
		assertFalse(target.isEnteringRange(weather));
	}

	@Test
	public void shouldNotEnterRangeIfNotNotifiedAndTempNotInRange() {
		WeatherData weather = new WeatherData("12345", 55.1, 0.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(0);
		target.setMaxHumidity(100);
		target.setInRangeNotified(false);
		target.setNotifyWhenTempEntersRange(true);
		assertFalse(target.isEnteringRange(weather));
	}

	@Test
	public void shouldEnterRangeIfNotNotifiedAndTempAtEdgeOfRange() {
		WeatherData weatherHigh = new WeatherData("12345", 55.0, 0.0);
		WeatherData weatherLow = new WeatherData("12345", 50.0, 0.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(0);
		target.setMaxHumidity(100);
		target.setInRangeNotified(false);
		target.setNotifyWhenTempEntersRange(true);
		assertTrue(target.isEnteringRange(weatherHigh));
		assertTrue(target.isEnteringRange(weatherLow));
	}

	@Test
	public void shouldEnterRangeIfNotNotifiedAndTempInRangeAndHumidityInRange() {
		WeatherData weather = new WeatherData("12345", 52.0, 50.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setNotifyOnlyWhenTempAndHumidityMatch(true);
		target.setNotifyWhenTempEntersRange(true);
		assertTrue(target.isEnteringRange(weather));
	}
	
	@Test
	public void shouldNotEnterRangeIfNotNotifiedAndTempInRangeAndHumidityNotInRange() {
		WeatherData weather = new WeatherData("12345", 52.0, 90.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setNotifyOnlyWhenTempAndHumidityMatch(true);
		target.setNotifyWhenTempEntersRange(true);
		assertFalse(target.isEnteringRange(weather));
	}

	@Test
	public void shouldLeaveRangeIfNotifiedInRangeAndNoLongerInRange() {
		WeatherData weather = new WeatherData("12345", 55.1, 50.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setInRangeNotified(true);
		target.setNotifyWhenTempEntersRange(true);
		target.setNotifyWhenTempLeavesRange(true);
		assertTrue(target.isLeavingRange(weather));
	}
	
	@Test
	public void shouldNotLeaveRangeIfNotNotifiedInRangeAndNoLongerInRange() {
		WeatherData weather = new WeatherData("12345", 55.1, 50.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setInRangeNotified(false);
		target.setNotifyWhenTempEntersRange(true);
		target.setNotifyWhenTempLeavesRange(true);
		assertFalse(target.isLeavingRange(weather));
	}
	
	@Test
	public void shouldLeaveRangeIfHumidityLeavesRangeEvenIfTempIsStillInRange() {
		WeatherData weather = new WeatherData("12345", 52.0, 90.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setInRangeNotified(true);
		target.setNotifyWhenTempEntersRange(true);
		target.setNotifyOnlyWhenTempAndHumidityMatch(true);
		target.setNotifyWhenTempLeavesRange(true);
		assertTrue(target.isLeavingRange(weather));
	}
	
	@Test
	public void shouldNotLeaveRangeIfStillInRange() {
		WeatherData weather = new WeatherData("12345", 52.0, 50.0);
		SubRequest target = new SubRequest();
		target.setMinTemp(50);
		target.setMaxTemp(55);
		target.setMinHumidity(25);
		target.setMaxHumidity(75);
		target.setInRangeNotified(true);
		target.setNotifyWhenTempEntersRange(true);
		target.setNotifyOnlyWhenTempAndHumidityMatch(true);
		target.setNotifyWhenTempLeavesRange(true);
		assertFalse(target.isLeavingRange(weather));
	}
	
	

}
