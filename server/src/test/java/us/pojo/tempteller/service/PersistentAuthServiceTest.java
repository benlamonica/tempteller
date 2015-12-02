package us.pojo.tempteller.service;

import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;

import org.easymock.EasyMock;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.StreamUtils;

import us.pojo.tempteller.model.auth.AuthResult;
import us.pojo.tempteller.model.auth.LoginRequest;
import us.pojo.tempteller.model.auth.Transaction;
import us.pojo.tempteller.model.auth.User;
import us.pojo.tempteller.service.auth.PersistentAuthService;
import us.pojo.tempteller.service.repository.TransactionRepository;
import us.pojo.tempteller.service.repository.UserRepository;
import us.pojo.tempteller.service.rule.RuleService;

public class PersistentAuthServiceTest {

	private UserRepository mockUserRepo;
	private TransactionRepository mockTxnRepo;
	private RuleService mockRuleService;
	
	private PersistentAuthService target;
	@Before
	public void setup() {
		mockUserRepo = EasyMock.createMock(UserRepository.class);
		mockTxnRepo = EasyMock.createMock(TransactionRepository.class);
		mockRuleService = EasyMock.createMock(RuleService.class);
		target = new PersistentAuthService();
		target.setRuleService(mockRuleService);
		target.setTxns(mockTxnRepo);
		target.setUsers(mockUserRepo);
	}
	
	@After
	public void verify() {
		EasyMock.verify(mockRuleService, mockTxnRepo, mockUserRepo);
	}
	
	private void replay() {
		EasyMock.replay(mockRuleService, mockTxnRepo, mockUserRepo);
	}
	
	// SCENARIOS
	// 1: User installs app for first time, with no sign of prior installs (iCloud rules empty, Push Id empty, keychain empty)
	//		a. configure as a new user
	//		b. register device for push notifications
	//		c. grant user 7 day trial subscription
	//		d. return sub end date
	private AuthResult loginNewUser() {
		expect(mockUserRepo.findOne("-1")).andReturn(null);
		expect(mockUserRepo.save(isA(User.class))).andReturn(null);
		replay();
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
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		expect(mockUserRepo.findOne("abc-def")).andReturn(new User("abc-def", new Date()));
		replay();
		AuthResult result = target.login(new LoginRequest("abc-def", "-1", null, "America/Chicago"));
		
		assertEquals("subEndDate", df.format(new Date()), result.subEndDate);
		assertEquals("uid", "abc-def", result.uid);
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
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		String receipt = StreamUtils.copyToString(new ClassPathResource("receipt.txt").getInputStream(), Charset.forName("utf8"));
		expect(mockTxnRepo.findAll(isA(Iterable.class))).andReturn(Collections.singletonList(new Transaction("11000000175854771", new User("abc-def", df.parse("2018-11-12")))));
		replay();	
		AuthResult restoreResult = target.restoreSubscription("-1", "599099EC-1DB4-4B30-92B3-F22FEEB57949", receipt);
		assertEquals("abc-def", restoreResult.uid);
		assertEquals("2018-10-21", restoreResult.subEndDate);
	}
	// 4: User purchases a subscription
	//		a. verify receipt
	//		b. verify that receipt isn't in use on more than 20 active devices
	//		c. return new sub end date

	@SuppressWarnings("unchecked")
	@Test
	public void userPurchasedSub() throws Exception {
		expect(mockTxnRepo.save(isA(Iterable.class))).andReturn(null);
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		expect(mockUserRepo.findOne("abc-def")).andReturn(new User("abc-def", df.parse("2018-10-21")));
		replay();
		String receipt = StreamUtils.copyToString(new ClassPathResource("receipt.txt").getInputStream(), Charset.forName("utf8"));
		AuthResult result = target.addSubscription("abc-def", "599099EC-1DB4-4B30-92B3-F22FEEB57949", receipt);
		assertEquals("2018-10-21", result.subEndDate);
	}

}
