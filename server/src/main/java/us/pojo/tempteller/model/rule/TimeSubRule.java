package us.pojo.tempteller.model.rule;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.annotation.JsonIgnore;

public class TimeSubRule extends SubRule {
	private static final Logger log = LoggerFactory.getLogger(TimeSubRule.class);
	public static class TimeRange {
		public String min;
		public String max;
		@Override
		public String toString() {
			return "TimeRange [min=" + min + ", max=" + max + "]";
		}
	}

	private TimeRange timeRange;
	private String op;

	public TimeRange getTimeRange() {
		return timeRange;
	}

	public void setTimeRange(TimeRange timeRange) {
		this.timeRange = timeRange;
	}

	public String getOp() {
		return op;
	}

	public void setOp(String op) {
		this.op = op;
	}

	private Date parseDate(SimpleDateFormat df, String date) {
		try {
			return df.parse(timeRange.min);
		} catch (ParseException e) {
			log.warn("Unable to parse date: '{}'", date);
			return null;
		}
	}
	
	@JsonIgnore
	public boolean isActive(Date date, TimeZone tz) {
		SimpleDateFormat df = new SimpleDateFormat("hh:mm a");
		df.setTimeZone(tz);
		Date min = parseDate(df, timeRange.min);
		if ("AT".equalsIgnoreCase(op)) {
			return date.equals(min);
		} else {
			if (min == null || date.before(min)) {
				return false;
			}
			
			Date max = parseDate(df, timeRange.max);
			if (max == null || date.after(max)) {
				return false;
			}
			
			return true;
		}
	}
	
	@Override
	public String toString() {
		return "TimeSubRule [timeRange=" + timeRange + ", op=" + op + "]";
	}

	@Override
	public boolean ruleMatches(Date now, TimeZone tz, WeatherData data) {
		return isActive(now, tz);
	}

}
