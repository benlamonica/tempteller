package us.pojo.tempteller.service;

import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import us.pojo.tempteller.dao.SubDAO;
import us.pojo.tempteller.model.SubRequest;
import us.pojo.tempteller.model.WeatherData;
import us.pojo.tempteller.service.push.PushService;
import us.pojo.tempteller.service.weather.WeatherService;

public class SubManagerImpl implements SubManager {

	private static final Logger log = LoggerFactory.getLogger(SubManagerImpl.class);
	
	@Autowired
	private SubDAO subDAO;
	
	@Autowired
	private WeatherService weather;
	
	@Autowired
	private PushService push;
	
	private BlockingQueue<Runnable> queue = new ArrayBlockingQueue<Runnable>(1000); 
	private ExecutorService threadPool = new ThreadPoolExecutor(2, 2, 10, TimeUnit.SECONDS, queue);
	private Timer t = new Timer();
	public SubManagerImpl() {
		t.schedule(new TimerTask() {
			@Override
			public void run() {
				notifySubscribers();
			}
		}, 30*1000, 15 * 60 * 1000);
		
		t.schedule(new TimerTask() {
			@Override
			public void run() {
				CLEANUP_NOTIFICATIONS.run();
			}
			
		}, 45*1000, 15*60*1000);
	}
	
//	private String getTempAndHumidityWithUnits(SubRequest req, WeatherData data) {
//		DecimalFormat df = new DecimalFormat("#00.#");
//		String temp;
//		if (!req.isFarenheitToBeUsed()) {
//			temp = df.format((data.getTemperature() - 32) * (5.0/9.0)) + "°C";
//		} else {
//			temp = df.format(data.getTemperature()) + "°F";
//		}
//		
//		return String.format("%s/%s%% humidity", temp, df.format(data.getHumidity()));
//	}
	
	private final Runnable CLEANUP_NOTIFICATIONS = new Runnable() {
		public void run() {
			Set<String> invalidDevices = push.getInvalidDevices();
			subDAO.deleteInvalidDevices(invalidDevices);
		}
	};
	
	private class FETCH_AND_NOTIFY implements Runnable {
		private String woeId;
		public FETCH_AND_NOTIFY(String woeId) {
			this.woeId = woeId;
		}
		public void run() {
			log.info("fetching data for {}", woeId);
			WeatherData data = weather.getWeather(woeId);
			log.info("fetched data {}", data);
			if (data != null) {
				log.info("Getting subscribers for {}", data);
				List<SubRequest> subscribers = subDAO.getSubscribers(data);
				log.info("Retrieved {} subscribers", subscribers.size());
				// TODO: perform the matching with the new data model.
//				for (SubRequest subRequest : subscribers) {
//					if (subRequest.isEnteringRange(data)) {
//						String msg = String.format("%s: Temp (%s) entered range. %s", subRequest.getName(), getTempAndHumidityWithUnits(subRequest, data), subRequest.getNoteEnter());
//						push.push(msg, subRequest.getDeviceId());
//						subRequest.setInRangeNotified(true);
//						subDAO.update(subRequest);
//					} else if (subRequest.isLeavingRange(data)){
//						String msg = String.format("%s: Temp (%s) left range. %s", subRequest.getName(), getTempAndHumidityWithUnits(subRequest, data), subRequest.getNoteLeave());
//						push.push(msg, subRequest.getDeviceId());
//						subRequest.setInRangeNotified(false);
//						subDAO.update(subRequest);
//					}
//				}
			}
		}
	}
	
	public boolean subscribe(SubRequest req) {
		if (req == null) {
			log.info("null rule received, doing nothing.");
			return false;
		}

		log.info("subscribing: {}", req);
		return subDAO.save(req);
	}

	public void notifySubscribers() {
		Set<String> ids = subDAO.getUniqueLocIds();
		log.info("Notifying subscribers for {} woeIds", ids.size());
		for (String woeId : ids) {
			threadPool.execute(new FETCH_AND_NOTIFY(woeId));
		}
	}

	public void unsubscribe(String deviceId) {
		subDAO.deleteInvalidDevices(Collections.singleton(deviceId));
	}
}
