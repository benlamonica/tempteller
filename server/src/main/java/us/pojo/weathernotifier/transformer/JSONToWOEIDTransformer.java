package us.pojo.weathernotifier.transformer;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class JSONToWOEIDTransformer {

	private Pattern FIND_WOEID = Pattern.compile("\\\"?woeid\\\"?[:>]\\\"?(\\d+)");
	
	public String transform(String json) {
		if (json != null) {
			Matcher m = FIND_WOEID.matcher(json);
			if (m.find()) {
				return m.group(1);
			}
		}
		
		return null;
	}
}
