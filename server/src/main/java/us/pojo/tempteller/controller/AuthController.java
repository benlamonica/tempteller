package us.pojo.tempteller.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.UserInfo;
import us.pojo.tempteller.service.auth.AuthService;

@Controller
public class AuthController {

	private static final Logger log = LoggerFactory.getLogger(AuthController.class);
	
	@Autowired
	private AuthService auth;
	
	public void setAuth(AuthService auth) {
		this.auth = auth;
	}

	@RequestMapping(value="{uid}/login", method=RequestMethod.POST)
	public @ResponseBody AuthResult login(@PathVariable("uid") String uid, @RequestParam("pushToken") String pushToken, @RequestParam(value="oldPushToken", required=false) String oldPushToken, @RequestParam("timezone") String timezone) {
		log.info("login: uid '{}' push '{}' oldPush '{}' tz '{}'", uid, pushToken, oldPushToken, timezone);
		UserInfo user = new UserInfo(uid, pushToken, oldPushToken, timezone);
		AuthResult result = auth.login(user);
		log.info("login: uid '{}' - {}", uid, result);
		return result;
	}
	
	// deviceId is used in computing the validity of the receipt
	@RequestMapping(value="{uid}/subscribe", method=RequestMethod.POST)
	public @ResponseBody AuthResult subscribe(@RequestBody String receipt, @PathVariable("uid") String uid, @RequestParam("deviceId") String deviceId) {
		log.info("sub: uid '{}' device '{}' receipt: {}", uid, deviceId, receipt);
		AuthResult result;
		if ("-1".equals(uid)) {
			result = auth.restoreSubscription(deviceId, receipt);
		} else {
			result = auth.addSubscription(uid, deviceId, receipt);
		}
		log.info("sub: uid '{}' - {}", uid, result);
		return result;
	}
}
