package us.pojo.tempteller.controller;

import java.util.TimeZone;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import us.pojo.tempteller.model.rule.Rule;
import us.pojo.tempteller.service.rule.RuleService;

@Controller
public class RuleController {

	private static final Logger log = LoggerFactory.getLogger(RuleController.class);
	
	@Autowired
	RuleService ruleService;
	
	
	@RequestMapping(value="{uid}/rules", method=RequestMethod.POST)
	public @ResponseBody String saveRules(@PathVariable(value="uid") String uid, @RequestParam(value="pushToken") String pushToken, @RequestParam(value="tz") String tz, @RequestBody Rule[] rules) {
		log.info("Saving {} rules for uid {}/{}", rules.length, uid, pushToken);
		TimeZone timeZone = TimeZone.getTimeZone(tz);
		for(Rule rule : rules) {
			ruleService.saveRule(uid, pushToken, rule, timeZone);
		}
		return "OK";
	}

	@RequestMapping(value="{uid}/rule/{ruleId}/delete", method=RequestMethod.POST) // putting the verb at the end and using post, because some proxies block DELETEs
	public String deleteRule(@PathVariable("uid") String uid, @RequestParam("pushToken") String pushToken, @PathVariable("ruleId") String ruleId) {
		log.info("Deleting rule {} for uid {}/{}", ruleId, uid, pushToken);
		ruleService.delete(uid,pushToken,ruleId);
		return "OK";
	}

	@RequestMapping(value="{uid}/rule/{ruleId}", method=RequestMethod.POST) // putting the verb at the end and using post, because some proxies block DELETEs
	public String saveRule(@PathVariable("uid") String uid, @RequestParam("pushToken") String pushToken, @PathVariable("ruleId") String ruleId, @RequestBody Rule rule, @RequestParam("tz") String tz) {
		log.info("Saving rule {} for uid {}/{}", ruleId, uid, pushToken);
		TimeZone timeZone = TimeZone.getTimeZone(tz);
		ruleService.saveRule(uid, pushToken, rule, timeZone);
		return "OK";
	}

	@RequestMapping(value="{uid}/rules", method=RequestMethod.GET)
	public Rule[] getRules(@PathVariable(value="uid") String uid) {
		log.info("Requesting rules for uid {}", uid);
		return ruleService.getRules(uid).stream().map(m -> m.getRule()).collect(Collectors.toList()).toArray(new Rule[] {});
	}
}
