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
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		String uri = request.getRequestURI();
		String userId = null;
		String endpoint = null;
		if (uri != null) {
			String[] uriSplit = uri.split("/");
			userId = uriSplit[0];
			endpoint = uriSplit[1];
		}
		
		String pushToken = request.getParameter("pushToken");
		
		MDC.clear();
		MDC.put("user_id", "uid:"+userId);
		MDC.put("endpoint", "endpoint:"+endpoint);
		MDC.put("push_token", "tkn:"+pushToken);
		
		log.info("{} {}\n{}", request.getMethod(), request.getRequestURI(), StreamUtils.copyToString(request.getInputStream(), Charset.forName(request.getCharacterEncoding())));
		return super.preHandle(request, response, handler);
	}

}
