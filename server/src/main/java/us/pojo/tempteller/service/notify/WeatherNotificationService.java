package us.pojo.tempteller.service.notify;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.rule.LocationSubRule;
import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.WeatherData;
import us.pojo.tempteller.service.push.PushService;
import us.pojo.tempteller.service.rule.RuleService;
import us.pojo.tempteller.service.weather.WeatherService;

@Service(value="WeatherNotificationService")
public class WeatherNotificationService implements Runnable {

	private static final Logger log = LoggerFactory.getLogger(WeatherNotificationService.class);
	
	private Thread t;
	
	@Autowired(required=true)
	private RuleService ruleService;
	public void setRuleService(RuleService ruleService) { this.ruleService = ruleService; }
	
	@Autowired(required=true)
	private WeatherService weatherService;
	public void setWeatherService(WeatherService weatherService) { this.weatherService = weatherService; }
	
	@Autowired(required=true)
	private PushService pushService;
	public void setPushService(PushService pushService) { this.pushService = pushService; }
	
	@PostConstruct
	public void init() {
		t = new Thread(this, "WeatherNotifierThread");
		t.setDaemon(true);
		t.start();
	}

	public void runOnce() {
		try {
			long startGetRules = System.currentTimeMillis();
			log.info("Checking for rules to notify.");
			List<NotifiableRule> rules = ruleService.getActiveRules();
			// all required weather data for this run
			List<LocationSubRule> locations = rules.stream()
					.map(r->r.getLocations())
					.flatMap(l->l.stream())
					.collect(Collectors.toList());
			
			Map<LocationSubRule, WeatherData> weather = new ConcurrentHashMap<>();
			
			log.info("{} rules to check, with {} locations total in {} ms", rules.size(), locations.size(), (System.currentTimeMillis() - startGetRules));
			long startTime = System.currentTimeMillis();
			log.info("Starting to gather weather data");
			Date now = new Date();
			locations.parallelStream()
				.forEach(
					l->weather.put(l, weatherService.getWeather(l.getLocId(), l.getLat(), l.getLng(), now.getTime(), now.getTime()))
				);
			log.info("Finished gathering {} pieces of weather data in {} ms", locations.size(), (System.currentTimeMillis() - startTime));
			
			// send the messages
			log.info("Starting to send messages");
			long startMsgs = System.currentTimeMillis();
			int msgsSent = rules.parallelStream()
				.filter(r->r.ruleMatches(now, weather))
				.map(r->{return pushService.push(r.getMessage(), r.getDecodedPushToken()) ? 1 : 0;})
				.reduce(0, Integer::sum);
			
			log.info("Sent {} messages in {} ms", msgsSent, System.currentTimeMillis() - startMsgs);
			
			cleanupInvalidDevices();
		} catch (Exception e) {
			log.error("Unexpected error while sending messages.", e);
		}
	}
	
	public void cleanupInvalidDevices() {
		log.info("Checking for invalid devices.");
		Set<String> invalidDevices = pushService.getInvalidDevices();
		log.info("Found {} invalid devices.", invalidDevices.size());
		if (!invalidDevices.isEmpty()) {
			ruleService.invalidateDevices(invalidDevices);
		}
	}
	
	@Override
	public void run() {
		while(true) {
			long start = System.currentTimeMillis();
			runOnce();
			long sleepTime = 60000 - (System.currentTimeMillis() - start);
			log.info("Sleeping {} ms before running again.", sleepTime);
			try { Thread.sleep(sleepTime); } catch (InterruptedException e) {}
		}
	}
}
