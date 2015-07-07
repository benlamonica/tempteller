package us.pojo.weathernotifier.transformer;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import us.pojo.weathernotifier.model.WOEID;

public class JSONToWOEIDTransformer {

	private Pattern FIND_WOEID = Pattern.compile("\\\"?woeid\\\"?[:>]\\\"?(\\d+)");
	
	public WOEID transform(String json) {
		if (json != null) {
			Matcher m = FIND_WOEID.matcher(json);
			if (m.find()) {
				return new WOEID(m.group(1));
			}
		}
		
		return new WOEID(null);
	}
}
