package us.pojo.tempteller.service.repository;

import java.util.stream.Stream;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import us.pojo.tempteller.model.rule.NotifiableRule;

public interface RuleRepository extends CrudRepository<NotifiableRule, NotifiableRule.RuleId> {
	@Query("from Rule")
	Stream<NotifiableRule> streamAllRules();
}
