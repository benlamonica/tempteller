package us.pojo.weathernotifier.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javapns.Push;
import javapns.devices.Device;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class JavaPNSFeedbackService implements FeedbackService {
	
	private final Logger log = LoggerFactory.getLogger(JavaPNSFeedbackService.class);
	private byte[] keystore;
	private String password;
	private boolean isProd;
	
	public JavaPNSFeedbackService(byte[] keystore, String password, boolean isProd) {
		this.keystore = keystore;
		this.password = password;
		this.isProd = isProd;
	}
	
	public List<String> getInvalidDeviceIds() {
		try {
			List<Device> invalidDevices = Push.feedback(keystore, password, isProd);
			ArrayList<String> devs = new ArrayList<String>();
			for (Device device : invalidDevices) {
				devs.add(device.getToken());
			}
			
			return devs;
		} catch (Exception e) {
			log.error("Unable to get feedback.", e);
			return Collections.emptyList();
		}
	}
}
