package us.pojo.tempteller.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Headers;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiParam;
import springfox.documentation.annotations.ApiIgnore;
import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.HeaderInfo;
import us.pojo.tempteller.model.auth.LoginRequest;
import us.pojo.tempteller.service.auth.AuthService;
import us.pojo.tempteller.service.rule.RuleService;

@Controller
public class AuthController {

	private static final Logger log = LoggerFactory.getLogger(AuthController.class);
	
	@Autowired
	private AuthService auth;
	
	@Autowired
	private RuleService rules;
	
	public void setAuth(AuthService auth) {
		this.auth = auth;
	}

	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
		@ApiImplicitParam(paramType="header",name="tz", value="TimeZone", example="America/Chicago", required=true)
	})
	@RequestMapping(value="/login", method=RequestMethod.POST,produces={"application/json"})
	public @ResponseBody AuthResult login(@ApiIgnore HeaderInfo headers, @ApiParam(value="prior base64 encoded push token, needed to transfer notifications over to new token")@RequestParam(value="oldPushToken", required=false) String oldPushToken) {
		log.info("login: oldPush='{}', tz='{}'", oldPushToken, headers.getTz());
		LoginRequest user = new LoginRequest(headers.getUid(), headers.getPushToken(), oldPushToken, headers.getTz());
		AuthResult result = auth.login(user);
		log.info("login result {}", result);
		return result;
	}

	// deviceId is used in computing the validity of the receipt
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
		@ApiImplicitParam(paramType="header",name="deviceId", value="hex-encoded device id", required=true)
	})
	@RequestMapping(value="/restore", method=RequestMethod.POST, produces={"application/json"})
	public @ResponseBody AuthResult restoreSubscription(@ApiIgnore HeaderInfo headers, @ApiParam(value="base64 encoded pkcs7 certificate")@RequestParam("receipt") String receipt) {
		log.info("restore subs: receipt: {}", receipt);
		AuthResult result = auth.restoreSubscription(headers.getUid(), headers.getDeviceId(), receipt);
		if (!result.uid.equals(headers.getUid())) {
			rules.transferPushTokenToNewUid(headers.getUid(), result.uid, headers.getPushToken());
		}
		log.info("restore subs result: {}", result);
		return result;
	}

	// deviceId is used in computing the validity of the receipt
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
		@ApiImplicitParam(paramType="header",name="deviceId", value="hex-encoded device id", required=true)
	})
	@RequestMapping(value="/subscribe", method=RequestMethod.POST, produces={"application/json"})
	public @ResponseBody AuthResult subscribe(@ApiIgnore HeaderInfo headers,  @ApiParam(value="base64 encoded pkcs7 certificate") @RequestParam("receipt") String receipt) {
		log.info("sub receipt: {}", receipt);
		AuthResult result = auth.addSubscription(headers.getUid(), headers.getDeviceId(), receipt);
		log.info("sub result: {}", result);
		return result;
	}
}
