package us.pojo.tempteller.service.push;

import java.util.Collections;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OfflinePushService implements PushService {

	private static final Logger log = LoggerFactory.getLogger(OfflinePushService.class);

	public void push(String msg, String deviceId) {
		log.info("Pushing %s to $s", msg, deviceId);
	}

	public Set<String> getInvalidDevices() {
		log.info("Getting Invalid Devices");
		return Collections.emptySet();
	}

}
