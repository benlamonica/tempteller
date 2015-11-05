package us.pojo.tempteller.service.auth;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.UserInfo;

/**
 * Dummy implementation of the AuthService..no db involved.
 * @author ben
 */
@Service
public class OfflineAuthService implements AuthService {

	private static class User {
		public Date subEndDate;
		public String pushToken;
		public String uid;
	}
	
	private static final Logger log = LoggerFactory.getLogger(OfflineAuthService.class);
	Map<String,User> users = new ConcurrentHashMap<>();
	
	@Override
	public AuthResult login(UserInfo userInfo) {
		String userLookup = userInfo.priorPushToken == null ? userInfo.pushToken : userInfo.priorPushToken;
		User user;
		if (users.containsKey(userLookup)) {
			user = users.get(userLookup);
		} else {
			Calendar cal = Calendar.getInstance();
			cal.add(Calendar.DAY_OF_MONTH, 10);
			user = new User();
			user.pushToken = userInfo.pushToken;
			user.subEndDate = new Date(System.currentTimeMillis() + (7 * 24 * 60 * 60 * 1000));
			user.uid = userInfo.uid;
			log.info("Creating New User uid: {}, subEndDate: {}, pushToken: {}", user.uid, user.subEndDate, user.pushToken);
			users.put(user.pushToken, user);
		}

		if (!user.pushToken.equals(userInfo.pushToken)) {
			log.info("Updating uid: {} pushtoken from {} to {}", userInfo.uid, userInfo.priorPushToken, userInfo.pushToken);
			user.pushToken = userInfo.pushToken;
		}
		
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		return new AuthResult(user.uid, df.format(user.subEndDate),"");
	}

	@Override
	public AuthResult addSubscription(String uid, String deviceId, String receipt) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public AuthResult restoreSubscription(String deviceId, String receipt) {
		// TODO Auto-generated method stub
		return null;
	}

}
