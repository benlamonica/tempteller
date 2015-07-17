package us.pojo.weathernotifier.transformer;

import static org.junit.Assert.assertEquals;

import java.io.IOException;
import java.io.InputStreamReader;

import org.junit.Test;
import org.springframework.util.FileCopyUtils;

import us.pojo.weathernotifier.model.WOEID;

public class JSONToWOEIDTransformerTest {

	@Test
	public void shouldConvertJSONToWOEID() throws IOException {
		JSONToWOEIDTransformer target = new JSONToWOEIDTransformer();
		String json = FileCopyUtils.copyToString(new InputStreamReader(getClass().getResourceAsStream("/json-woeid.json")));
		WOEID result = target.transform(json);
		assertEquals(result.getWOEID(), "12784194");
	}
	
	@Test
	public void shouldReturnWOEIDWithNullIdIfWOEIDNotFound() throws IOException {
		JSONToWOEIDTransformer target = new JSONToWOEIDTransformer();
		WOEID result = target.transform("");
		assertEquals(result.getWOEID(), null);
	}

}
