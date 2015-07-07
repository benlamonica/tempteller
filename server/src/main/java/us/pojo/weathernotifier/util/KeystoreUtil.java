package us.pojo.weathernotifier.util;

import java.io.IOException;
import java.io.InputStream;

import org.springframework.util.FileCopyUtils;

public class KeystoreUtil {
	
	public static byte[] getKeystore(String url) {
		InputStream in = KeystoreUtil.class.getResourceAsStream(url);
		try {
			return FileCopyUtils.copyToByteArray(in);
		} catch (IOException e) {
			throw new RuntimeException("Unable to read keystore", e);
		}
	}

}
