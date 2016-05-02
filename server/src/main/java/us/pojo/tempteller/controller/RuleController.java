package us.pojo.tempteller.controller;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import springfox.documentation.annotations.ApiIgnore;
import us.pojo.tempteller.model.auth.HeaderInfo;
import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.Rule;
import us.pojo.tempteller.service.rule.RuleService;

@Controller
public class RuleController {

	private static final Logger log = LoggerFactory.getLogger(RuleController.class);
	
	@Autowired
	RuleService ruleService;
	
	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
		@ApiImplicitParam(paramType="header",name="tz", value="TimeZone", example="America/Chicago", required=true)
	})
	@RequestMapping(value="/rules", method=RequestMethod.POST)
	public @ResponseBody String saveRules(@ApiIgnore HeaderInfo headers, @RequestBody Rule[] rules) {
		log.info("Saving {} rules", rules.length);
		Set<String> ruleIds = new HashSet<>();
		for(Rule rule : rules) {
			ruleIds.add(rule.getUuid());
			ruleService.saveRule(headers.getUid(), headers.getPushToken(), rule, headers.getTimeZone());
		}
		
		// delete rules that weren't sent up
		List<NotifiableRule> deviceRules = ruleService.getRules(headers.getUid()).stream().filter(r->r.getPushToken().equals(headers.getPushToken())).collect(Collectors.toList());
		deviceRules.stream()
			.filter(r->!ruleIds.contains(r.getRuleId()))
			.forEach(r->ruleService.delete(headers.getUid(), headers.getPushToken(), r.getRuleId()));
		
		log.info("Deleted {} existing rules", (deviceRules.size() - ruleIds.size()));
		
		return "OK";
	}

	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
	})
	@RequestMapping(value="/rules/{ruleId}", method=RequestMethod.DELETE)
	public @ResponseBody String deleteRule(@ApiIgnore HeaderInfo headers, @PathVariable("ruleId") String ruleId) {
		log.info("Deleting rule {}", ruleId);
		ruleService.delete(headers.getUid(), headers.getPushToken(), ruleId);
		return "OK";
	}

	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
		@ApiImplicitParam(paramType="header",name="pushToken", value="base64 encoded Apple Push Token", required=true),
		@ApiImplicitParam(paramType="header",name="tz", value="TimeZone", example="America/Chicago", required=true)
	})
	@RequestMapping(value="/rules/{ruleId}", method=RequestMethod.POST)
	public @ResponseBody String saveRule(@ApiIgnore HeaderInfo headers, @PathVariable("ruleId") String ruleId, @RequestBody Rule rule) {
		log.info("Saving rule {}", ruleId);
		ruleService.saveRule(headers.getUid(), headers.getPushToken(), rule, headers.getTimeZone());
		return "OK";
	}

	@ApiImplicitParams({
		@ApiImplicitParam(paramType="header",name="uid",value="uuid of user",required=true),
	})
	@RequestMapping(value="/rules", method=RequestMethod.GET)
	@ApiOperation(value="Returns all rules for all devices. Useful for when registering a new device.")
	public @ResponseBody Rule[] getRules(@ApiIgnore HeaderInfo headers) {
		log.info("Requesting rules");
		return ruleService.getRules(headers.getUid()).stream().map(m -> m.getRule()).collect(Collectors.toList()).toArray(new Rule[] {});
	}
}
