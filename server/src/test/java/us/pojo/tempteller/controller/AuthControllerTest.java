package us.pojo.tempteller.controller;

public class AuthControllerTest {

	// SCENARIOS
	// 1: User installs app for first time, with no sign of prior installs (iCloud rules empty, Push Id empty, keychain empty)
	//		a. configure as a new user
	//		b. register device for push notifications
	//		c. grant user 7 day trial subscription
	//		d. return sub end date
	// 2: User installs app on another device (keychain has userId, but device does not have Push Id)
	//		a. register device for push notifications
	//		b. return sub end date
	// 3: User is unknown to the app, but then restores subscriptions
	// 		a. configured as a new user
	//		b. register device for push notifications
	//		c. app sends receipt
	//		d. verify receipt
	//		e. verify that the receipt hasn't been used on more than 20 active devices
	//		f. return original userId and sub end date
	//		g. unregister the device under the old user
	// 4: User purchases a subscription
	//		a. verify receipt
	//		b. verify that receipt isn't in use on more than 20 active devices
	//		c. return new sub end date

}
