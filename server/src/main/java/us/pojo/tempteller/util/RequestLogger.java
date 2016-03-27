package us.pojo.tempteller.util;

import java.nio.charset.Charset;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.MDC;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StreamUtils;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

public class RequestLogger extends HandlerInterceptorAdapter {

	private static final Logger log = LoggerFactory.getLogger("access");
	
	private void setContextVariable(String key, HttpServletRequest req) {
		String val = req.getHeader(key);
		if (val != null) {
			MDC.put(key, " "+key+"="+val);
		}
	}
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		MDC.clear();
		setContextVariable("uid", request);
		setContextVariable("pushToken", request);
		setContextVariable("deviceId", request);
		
		if (request.getContentLength() > 0) {
			log.info("{} {}\n{}", request.getMethod(), request.getRequestURI(), StreamUtils.copyToString(request.getInputStream(), Charset.forName(request.getCharacterEncoding())));
		} else {
			log.info("{} {}", request.getMethod(), request.getRequestURI());
		}
		return super.preHandle(request, response, handler);
	}

}
