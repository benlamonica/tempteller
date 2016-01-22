package us.pojo.tempteller.service.repository;

import java.util.Collection;
import java.util.Date;
import java.util.stream.Stream;

import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.transaction.annotation.Transactional;

import us.pojo.tempteller.model.rule.NotifiableRule;

public interface RuleRepository extends CrudRepository<NotifiableRule, NotifiableRule.RuleId> {
	@Query("from Rule")
	Stream<NotifiableRule> streamAllRules();
	
	@Modifying
	@Transactional
	@Query("update Rule set isValid=false, lastUpdateTime=?2 where pushToken in ?1")
	int invalidatePushToken(Collection<String> invalidIds, Date now);
}
