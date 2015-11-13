package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

public class HumiditySubRule extends SingleValueSubRule {

	@Override
	public String toString() {
		return "HumiditySubRule [getValue()=" + getValue() + ", getOp()="
				+ getOp() + "]";
	}

	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		return compare(getOp(), data.getHumidity(), getValue());
	}

}
