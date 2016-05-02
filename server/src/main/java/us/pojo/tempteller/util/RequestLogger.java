package us.pojo.tempteller.util;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.MDC;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.filter.CommonsRequestLoggingFilter;

public class RequestLogger extends CommonsRequestLoggingFilter {

	private static final Logger log = LoggerFactory.getLogger("access");
	
	public RequestLogger() {
		super.setMaxPayloadLength(4096);
		super.setIncludePayload(true);
	}
	
	private void setContextVariable(String key, HttpServletRequest req) {
		String val = req.getHeader(key);
		if (val != null) {
			MDC.put(key, " "+key+"="+val);
		}
	}
	
	
	@Override
	protected void afterRequest(HttpServletRequest request, String message) {
		log.info(message);
	}


	@Override
	protected void beforeRequest(HttpServletRequest request, String message) {

	}

	@Override
	protected boolean shouldLog(HttpServletRequest request) {
		MDC.clear();
		setContextVariable("uid", request);
		setContextVariable("pushToken", request);
		setContextVariable("deviceId", request);
		return log.isInfoEnabled();
	}
}
