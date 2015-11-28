package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

public class MessageSubRule extends SubRule {
	private String message;

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@Override
	public String toString() {
		return "MessageSubRule [message=" + message + "]";
	}

	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		// messages don't evaluate, so just return true to move on to the next rule.
		return true;
	}

}
