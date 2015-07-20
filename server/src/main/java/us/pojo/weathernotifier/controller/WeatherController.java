package us.pojo.weathernotifier.controller;

import java.util.ArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import us.pojo.weathernotifier.model.Status;
import us.pojo.weathernotifier.model.SubRequest;
import us.pojo.weathernotifier.model.WOEID;
import us.pojo.weathernotifier.model.WeatherData;
import us.pojo.weathernotifier.service.SubManager;
import us.pojo.weathernotifier.service.push.PushService;
import us.pojo.weathernotifier.service.weather.WeatherService;

/**
 * device -> search for WOEID (my server) -> yahoo WOEID lookup -> result to my server -> device
 * device -> weather request with WOEID (my server) -> look up cache -> if cache is old, yahoo weather request -> result to my server -> device
 * device -> subscribe for weather request
 * my server -> poll weather with WOEID
 * 
 * @author ben
 *
 */

@Controller
@RequestMapping("/weather-notifier")
public class WeatherController {

	@Autowired
	private WeatherService weather;
	
	@Autowired
	private SubManager subManager;
	
	@Autowired
	private PushService pushService;
	
	private static final Logger log = LoggerFactory.getLogger(WeatherController.class);
	
	public WeatherController() {
		LoggerFactory.getLogger(WeatherController.class).info("WeatherNotifier instantiated!");
	}

	@RequestMapping("/WOEID/{query}")
	public @ResponseBody WOEID getWOEID(@PathVariable("query") String query) {
		return weather.getWOEID(query);
	}
	
	@RequestMapping("/weather/{woeid}")
	public @ResponseBody WeatherData getWeather(@PathVariable("woeid") String woeid) {
		return weather.getWeather(woeid);
	}
	
	@RequestMapping(method=RequestMethod.POST, value="/subscribe")
	public @ResponseBody Status[] subscribe(@RequestBody SubRequest[] subRequests) {
		ArrayList<Status> response = new ArrayList<Status>();
		
		if (subRequests.length > 0) {
			subManager.unsubscribe(subRequests[0].getDeviceId());
			for (SubRequest sub : subRequests) {
				log.info("Subscribing {}", sub);
				if (subManager.subscribe(sub)) {
					response.add(new Status(sub.getDeviceId(), sub.getWoeId(), "yep"));
				} else {
					response.add(new Status(sub.getDeviceId(), sub.getWoeId(), "nope"));
				}
			}
		}
		
		return response.toArray(new Status[response.size()]);
	}

}