package us.pojo.tempteller.transformer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.io.IOException;
import java.io.InputStreamReader;

import org.junit.Test;
import org.springframework.util.FileCopyUtils;

import us.pojo.tempteller.transformer.JSONToWOEIDTransformer;

public class JSONToWOEIDTransformerTest {

	@Test
	public void shouldConvertJSONToWOEID() throws IOException {
		JSONToWOEIDTransformer target = new JSONToWOEIDTransformer();
		String json = FileCopyUtils.copyToString(new InputStreamReader(getClass().getResourceAsStream("/json-woeid.json")));
		String result = target.transform(json);
		assertEquals(result, "12784194");
	}
	
	@Test
	public void shouldReturnWOEIDWithNullIdIfWOEIDNotFound() throws IOException {
		JSONToWOEIDTransformer target = new JSONToWOEIDTransformer();
		String result = target.transform("");
		assertNull(result);
	}

}
