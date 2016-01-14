package us.pojo.tempteller.service.notify;

import java.util.Date;
import java.util.List;
import java.util.Map;
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
	
	@Autowired(required=true)
	private WeatherService weatherService;
	
	@Autowired(required=true)
	private PushService pushService;
	
	@PostConstruct
	public void init() {
		t = new Thread(this, "WeatherNotifierThread");
		t.setDaemon(true);
		t.start();
	}

	@Override
	public void run() {
		while(true) {
			log.info("Checking for rules to notify for.");
			List<NotifiableRule> rules = ruleService.getActiveRules();
			// all required weather data for this run
			List<LocationSubRule> locations = rules.stream()
					.map(r->r.getLocations())
					.flatMap(l->l.stream())
					.collect(Collectors.toList());
			Map<LocationSubRule, WeatherData> weather = new ConcurrentHashMap<>();
			
			log.info("{} rules to check, with {} locations total", rules.size(), locations.size());
			long startTime = System.currentTimeMillis();
			log.info("Starting to gather weather data");
			Date now = new Date();
			locations.parallelStream()
				.forEach(
					k->weather.put(k, weatherService.getWeather(k.getLocId(), k.getLat(), k.getLng(), now.getTime(), now.getTime()))
				);
			log.info("Finished gathering weather data. {} ms", (System.currentTimeMillis() - startTime));
			
			
			try { Thread.sleep(10000); } catch (InterruptedException e) {}
			
		}
	}
}
