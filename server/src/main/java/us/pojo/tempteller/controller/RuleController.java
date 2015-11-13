package us.pojo.tempteller.controller;

import java.util.TimeZone;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import us.pojo.tempteller.model.rule.Rule;
import us.pojo.tempteller.service.rule.RuleService;

@Controller
public class RuleController {

	private static final Logger log = LoggerFactory.getLogger(RuleController.class);
	
	@Autowired
	RuleService ruleService;
	
	@RequestMapping(value="{uid}/{pushToken}/rules", method=RequestMethod.POST)
	public String saveRules(@RequestParam(value="uid") String uid, @RequestParam(value="pushToken") String pushToken, @RequestParam(value="tz") String tz, @RequestBody Rule[] rules) {
		TimeZone timeZone = TimeZone.getTimeZone(tz);
		for(Rule rule : rules) {
			ruleService.saveRule(uid, pushToken, rule, timeZone);
		}
		return "OK";
	}

	@RequestMapping(value="{uid}/{pushToken}/rule/{ruleId}", method=RequestMethod.DELETE)
	public String deleteRule(@RequestParam("uid") String uid, @RequestParam("pushToken") String pushToken, @RequestParam("ruleId") String ruleId) {
		log.info("Deleting rule {} for uid {}/{}", ruleId, uid, pushToken);
		ruleService.delete(uid,pushToken,ruleId);
		return "OK";
	}
	
	@RequestMapping(value="{uid}/rules", method=RequestMethod.GET)
	public Rule[] getRules(@RequestParam(value="uid") String uid) {
		log.info("Requesting rules for uid {}", uid);
		return ruleService.getRules(uid).stream().map(m -> m.rule).collect(Collectors.toList()).toArray(new Rule[] {});
	}
}
