package us.pojo.tempteller.service.rule;

import java.util.List;
import java.util.TimeZone;

import us.pojo.tempteller.model.rule.NotifiableRule;
import us.pojo.tempteller.model.rule.Rule;

public interface RuleService {

	void saveRule(String uid, String pushToken, Rule rule, TimeZone tz);

	void delete(String uid, String pushToken, String ruleId);

	List<NotifiableRule> getRules(String uid);

	List<NotifiableRule> getActiveRules(); 
}