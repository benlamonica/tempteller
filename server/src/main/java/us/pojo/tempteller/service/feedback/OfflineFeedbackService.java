package us.pojo.tempteller.service.feedback;

import java.util.Collections;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OfflineFeedbackService implements FeedbackService {

	private static final Logger log = LoggerFactory.getLogger(OfflineFeedbackService.class);
	public List<String> getInvalidDeviceIds() {
		log.info("Getting invalid deviceids");
		return Collections.emptyList();
	}

}
