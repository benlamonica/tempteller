package us.pojo.tempteller.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.UserInfo;
import us.pojo.tempteller.service.auth.AuthService;

@Controller
public class AuthController {

	@Autowired
	private AuthService auth;
	
	@RequestMapping(value="{uid}/login?pushToken={pushToken}&oldPushToken={oldPushToken}", method=RequestMethod.POST)
	public AuthResult login(@RequestParam("uid") String uid, @RequestParam("pushToken") String pushToken, @RequestParam(value="oldPushToken", required=false) String oldPushToken) {
		UserInfo user = new UserInfo(uid, pushToken, oldPushToken);
		return auth.login(user);
	}
	
	// deviceId is used in computing the validity of the receipt
	@RequestMapping(value="{uid}/subscribe?deviceId={deviceId}", method=RequestMethod.POST)
	public AuthResult subscribe(@RequestBody String receipt, @RequestParam("uid") String uid, @RequestParam("deviceId") String deviceId) {
		if (uid.equals("-1")) {
			return auth.restoreSubscription(deviceId, receipt);
		} else {
			return auth.addSubscription(uid, deviceId, receipt);
		}
	}
}
