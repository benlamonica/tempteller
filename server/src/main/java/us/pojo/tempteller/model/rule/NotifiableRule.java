package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.stream.Collectors;

public class NotifiableRule {
	public Rule rule;
	public String uid;
	public String pushToken;
	public TimeZone tz;
	public Date lastNotify;
	
	public List<String> getLocations() {
		return rule.getSubrules().stream().filter(r -> r instanceof LocationSubRule)
				.map(l -> ((LocationSubRule) l).getLocId()).collect(Collectors.toList());
	}
	
	public boolean isActive(Date now) {
		if ((lastNotify.getTime() + (1 * 60 * 1000)) > now.getTime()) {
			return false;
		}
		
		List<SubRule> timeRule = rule.getSubrules().stream().filter(r -> r instanceof TimeSubRule).collect(Collectors.toList());
		if (!timeRule.isEmpty()) {
			TimeSubRule tr = (TimeSubRule) timeRule.get(0);
			return tr.isActive(new Date(), tz);
		}
		return true;
	}
	
	public boolean ruleMatches(Date now, Map<String,WeatherData> weatherData) {
		if (!isActive(now)) {
			return false;
		}

		LocationSubRule loc = (LocationSubRule) rule.getSubrules().get(1);
		WeatherData data = weatherData.get(loc.getLocId());
		boolean matches = true;
		for(int i = 3; matches && i < rule.getSubrules().size(); i++) {
			SubRule subrule = rule.getSubrules().get(i);
			if (subrule instanceof LocationSubRule) {
				loc = (LocationSubRule) rule.getSubrules().get(1);
				data = weatherData.get(loc.getLocId());
				continue;
			}
			matches = subrule.ruleMatches(now, tz, data);
		}
		
		lastNotify.setTime(now.getTime());
		return true;
	}
}
