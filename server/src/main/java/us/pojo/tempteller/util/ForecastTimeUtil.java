package us.pojo.tempteller.util;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ForecastTimeUtil {
	private static final Logger log = LoggerFactory.getLogger(ForecastTimeUtil.class);
	private static final Pattern DATE_PATTERN = Pattern.compile("(:?(Today|Tomorrow|\\d+ Days) @ )(\\d{2}:\\d{2} \\S+)");

	@SuppressWarnings("serial")
	private static final Map<String,Integer> DAY_MAP = new HashMap<String, Integer>() {
		{ 
			put("Today", 0);
			put("Tomorrow", 1);
			put("3 Days", 2);
			put("4 Days", 3);
			put("5 Days", 4);
			put("6 Days", 5);
			put("7 Days", 6);
		}
	};

	public static Date getForecastTimeAsDate(String time, TimeZone tz) {
		SimpleDateFormat df = new SimpleDateFormat("hh:mm a");
		df.setTimeZone(tz);

		Matcher m = DATE_PATTERN.matcher(time);
		Date forecastTime = new Date();
		if (m.find()) {
			try {
				forecastTime = df.parse(m.group(2));
			} catch (Exception e) {
				log.warn("Unable to parse '{}'", forecastTime);
			}
			
			if (m.group(1) != null) {
				Integer days = DAY_MAP.get(m.group(1));
				if (days != null) {
					forecastTime.setTime(forecastTime.getTime() + (days * 24 * 60 * 60 * 1000));
				}
			}
		}
		
		return forecastTime;
	}

}
