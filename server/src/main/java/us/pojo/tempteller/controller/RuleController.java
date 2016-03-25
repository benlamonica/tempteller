package us.pojo.tempteller.controller;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TimeZone;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.Rule;
import us.pojo.tempteller.service.rule.RuleService;

@Controller
public class RuleController {

	private static final Logger log = LoggerFactory.getLogger(RuleController.class);
	
	@Autowired
	RuleService ruleService;
	
	@RequestMapping(value="/rules", method=RequestMethod.POST)
	public @ResponseBody String saveRules(@Header(value="uid") String uid, @RequestParam(value="device") String pushToken, @RequestParam(value="tz") String tz, @RequestBody Rule[] rules) {
		log.info("Saving {} rules for uid {}/{}", rules.length, uid, pushToken);
		TimeZone timeZone = TimeZone.getTimeZone(tz);
		Set<String> ruleIds = new HashSet<>();
		for(Rule rule : rules) {
			ruleIds.add(rule.getUuid());
			ruleService.saveRule(uid, pushToken, rule, timeZone);
		}
		
		// delete rules that weren't sent up
		List<NotifiableRule> deviceRules = ruleService.getRules(uid).stream().filter(r->r.getPushToken().equals(pushToken)).collect(Collectors.toList());
		deviceRules.stream()
			.filter(r->!ruleIds.contains(r.getRuleId()))
			.forEach(r->ruleService.delete(uid, pushToken, r.getRuleId()));
		
		log.info("Deleted {} existing rules for uid {}/{}", (deviceRules.size() - ruleIds.size()), uid, pushToken);
		
		return "OK";
	}

	@RequestMapping(value="{uid}/rule/{ruleId}/delete", method=RequestMethod.POST) // putting the verb at the end and using post, because some proxies block DELETEs
	public @ResponseBody String deleteRule(@PathVariable("uid") String uid, @RequestParam("pushToken") String pushToken, @PathVariable("ruleId") String ruleId) {
		log.info("Deleting rule {} for uid {}/{}", ruleId, uid, pushToken);
		ruleService.delete(uid,pushToken,ruleId);
		return "OK";
	}

	@RequestMapping(value="{uid}/rule/{ruleId}", method=RequestMethod.POST)
	public @ResponseBody String saveRule(@PathVariable("uid") String uid, @RequestParam("pushToken") String pushToken, @PathVariable("ruleId") String ruleId, @RequestBody Rule rule, @RequestParam("tz") String tz) {
		log.info("Saving rule {} for uid {}/{}", ruleId, uid, pushToken);
		TimeZone timeZone = TimeZone.getTimeZone(tz);
		ruleService.saveRule(uid, pushToken, rule, timeZone);
		return "OK";
	}

	@RequestMapping(value="{uid}/rules", method=RequestMethod.GET)
	public @ResponseBody Rule[] getRules(@PathVariable(value="uid") String uid) {
		log.info("Requesting rules for uid {}", uid);
		return ruleService.getRules(uid).stream().map(m -> m.getRule()).collect(Collectors.toList()).toArray(new Rule[] {});
	}
}
