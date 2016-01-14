package us.pojo.tempteller.service.push;

import java.util.HashSet;
import java.util.Set;

import javax.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javapns.notification.PushNotificationPayload;
import javapns.notification.PushedNotification;
import javapns.notification.PushedNotifications;
import javapns.notification.transmission.PushQueue;
import us.pojo.tempteller.service.feedback.FeedbackService;

@Service(value="PushService")
public class JavaPNSPushService implements PushService {

	private final Logger log = LoggerFactory.getLogger(JavaPNSPushService.class);
	
	@Autowired(required=true)
	private PushQueue queue;
	
	@Autowired(required=true)
	private FeedbackService feedback;
	
	@PostConstruct
	public void start() {
		this.queue.start();
	}
	
	public void push(String msg, String deviceId) {
		try {
			PushNotificationPayload payload = PushNotificationPayload.complex();
			payload.addAlert(msg);
			synchronized (queue) {
				queue.add(payload, deviceId);
			}
		} catch (Exception e) {
			log.error("Sending msg {} caused an issue", msg, e);
		}
	}

	public Set<String> getInvalidDevices() {
		PushedNotifications notifications;
		synchronized(queue) {
			notifications = queue.getPushedNotifications();
			queue.clearPushedNotifications();
		}
		Set<String> invalidDevices = new HashSet<String>();
		log.info("Processed {} messages", notifications.size());
		for (PushedNotification n : notifications) {
			if (!n.isSuccessful()) {
				log.warn(String.format("Unsubscribing device %s because %s-%s", n.getDevice().getToken(), n.getResponse().getStatus(), n.getResponse().getMessage()), n.getException());
				invalidDevices.add(n.getDevice().getToken());
			}
		}

		invalidDevices.addAll(feedback.getInvalidDeviceIds());
		
		return invalidDevices;
	}
}
