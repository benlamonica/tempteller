package us.pojo.tempteller.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import us.pojo.tempteller.model.weather.Rule;

@Controller
public class RuleController {

	@RequestMapping(value="{uid}/{pushToken}/rules", method=RequestMethod.POST)
	public String saveRules(@RequestParam(value="uid") String uid, @RequestParam(value="pushToken") String pushToken, @RequestBody Rule[] rules) {
		return "OK";
	}

	@RequestMapping(value="{uid}/{pushToken}/rule/{ruleId}", method=RequestMethod.DELETE)
	public String deleteRule(@RequestParam("uid") String uid, @RequestParam("pushToken") String pushToken, @RequestParam("ruleId") String ruleId) {
		return "OK";
	}
	
	@RequestMapping(value="{uid}/rules", method=RequestMethod.GET)
	public Rule[] getRules(@RequestParam(value="uid") String uid) {
		return new Rule[] {new Rule()};
	}
}
