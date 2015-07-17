package us.pojo.weathernotifier.service.push;

import java.util.HashSet;
import java.util.Set;

import javapns.notification.PushNotificationPayload;
import javapns.notification.PushedNotification;
import javapns.notification.PushedNotifications;
import javapns.notification.transmission.PushQueue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import us.pojo.weathernotifier.service.feedback.FeedbackService;

public class JavaPNSPushService implements PushService {

	private final Logger log = LoggerFactory.getLogger(JavaPNSPushService.class);
	
	private PushQueue queue;
	
	private FeedbackService feedback;
	
	public JavaPNSPushService(PushQueue queue, FeedbackService feedback) {
		this.queue = queue;
		this.queue.start();
		this.feedback = feedback;
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
