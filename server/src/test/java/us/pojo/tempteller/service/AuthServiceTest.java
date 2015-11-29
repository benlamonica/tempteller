package us.pojo.tempteller.service;

import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Date;

import static org.junit.Assert.*;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.LoginRequest;
import us.pojo.tempteller.service.auth.AuthService;
import us.pojo.tempteller.service.auth.OfflineAuthService;

public class AuthServiceTest {

	private AuthService target;
	@Before
	public void setup() {
		target = new OfflineAuthService();
	}
	
	@After
	public void verify() {

	}
	// SCENARIOS
	// 1: User installs app for first time, with no sign of prior installs (iCloud rules empty, Push Id empty, keychain empty)
	//		a. configure as a new user
	//		b. register device for push notifications
	//		c. grant user 7 day trial subscription
	//		d. return sub end date
	private AuthResult loginNewUser() {
		AuthResult result = target.login(new LoginRequest("-1","-1", null, "America/Chicago"));
		return result;
	}
	
	@Test
	public void newUser() {
		AuthResult result = loginNewUser();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		String expectedSubEnd = df.format(new Date(System.currentTimeMillis() + (7*24*60*60*1000)));
		assertEquals(expectedSubEnd, result.subEndDate);
		assertFalse("uid is still -1", result.uid.equals("-1"));
	}
	
	// 2: User installs app on another device (keychain has userId, but device does not have Push Id)
	//		a. register device for push notifications
	//		b. return sub end date
	@Test
	public void differentDevice() {
		AuthResult newUserResult = loginNewUser();
		AuthResult result = target.login(new LoginRequest(newUserResult.uid, "-1", null, "America/Chicago"));
		assertEquals("subEndDate", newUserResult.subEndDate, result.subEndDate);
		assertEquals("uid", newUserResult.uid, result.uid);
	}
	
	// 3: User is unknown to the app, but then restores subscriptions
	// 		a. configured as a new user
	//		b. register device for push notifications
	//		c. app sends receipt
	//		d. verify receipt
	//		e. verify that the receipt hasn't been used on more than 20 active devices
	//		f. return original userId and sub end date
	//		g. unregister the device under the old user
	@Test
	public void wipedAppAndKeychainInstall() throws Exception {
		AuthResult loginResult = loginNewUser();
		String receipt = StreamUtils.copyToString(new ClassPathResource("receipt.txt").getInputStream(), Charset.forName("utf8"));
		AuthResult subResult = target.addSubscription(loginResult.uid, "599099EC-1DB4-4B30-92B3-F22FEEB57949", receipt);
		assertEquals("2018-10-21", subResult.subEndDate);
		AuthResult restoreResult = target.restoreSubscription("-1", "599099EC-1DB4-4B30-92B3-F22FEEB57949", receipt);
		assertEquals(loginResult.uid, restoreResult.uid);
		assertEquals("2018-10-21", restoreResult.subEndDate);
	}
	// 4: User purchases a subscription
	//		a. verify receipt
	//		b. verify that receipt isn't in use on more than 20 active devices
	//		c. return new sub end date

	@Test
	public void userPurchasedSub() throws Exception {
		AuthResult loginResult = loginNewUser();
		String receipt = StreamUtils.copyToString(new ClassPathResource("receipt.txt").getInputStream(), Charset.forName("utf8"));
		AuthResult result = target.addSubscription(loginResult.uid, "599099EC-1DB4-4B30-92B3-F22FEEB57949", receipt);
		assertEquals("2018-10-21", result.subEndDate);
	}

}
