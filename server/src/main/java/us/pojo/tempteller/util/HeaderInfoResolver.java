package us.pojo.tempteller.util;

import java.net.URLDecoder;

import org.springframework.core.MethodParameter;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

import us.pojo.tempteller.model.auth.HeaderInfo;

@Component
public class HeaderInfoResolver implements HandlerMethodArgumentResolver {

	@Override
	public Object resolveArgument(MethodParameter param, ModelAndViewContainer mav, NativeWebRequest req, WebDataBinderFactory bind) throws Exception {
		String uid = req.getHeader("uid");
		String deviceId = req.getHeader("deviceId");
		String pushToken = req.getHeader("pushToken");
		String tz = req.getHeader("tz");
		
		if (tz != null) {
			tz = URLDecoder.decode(tz, "utf-8");
		}
		return new HeaderInfo(uid, pushToken, deviceId, tz);
	}

	@Override
	public boolean supportsParameter(MethodParameter param) {
		return param.getParameterType().equals(HeaderInfo.class);
	}
}
