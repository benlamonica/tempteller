package us.pojo.tempteller.model.rule;

import java.io.IOException;
import java.io.Serializable;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.stream.Collectors;

import javax.persistence.Access;
import javax.persistence.AccessType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectReader;
import com.fasterxml.jackson.databind.ObjectWriter;

@Entity(name="Rule")
@Table(name="Rule")
@IdClass(NotifiableRule.RuleId.class)
@Access(AccessType.FIELD)
public class NotifiableRule {
	
	private static final Logger log = LoggerFactory.getLogger(NotifiableRule.class);
	
	private static ObjectMapper JSON_MAPPER = new ObjectMapper();
	private static ObjectReader FROM_JSON = JSON_MAPPER.readerFor(Rule.class);
	private static ObjectWriter TO_JSON = JSON_MAPPER.writerFor(Rule.class);
	
	@Id
	private String uid;
	@Id
	private String pushToken;
	@Id
	private String ruleId;
	
	@Transient
	private Rule rule;
	
	private String tz;
	
	@Transient
	private TimeZone timezone;
	
	private Date lastNotify;
	
	public List<String> getLocations() {
		return rule.getSubrules().stream().filter(r -> r instanceof LocationSubRule)
				.map(l -> ((LocationSubRule) l).getLocId()).collect(Collectors.toList());
	}
	
	public boolean isActive(Date now) {
		if ((lastNotify.getTime() + (1 * 60 * 1000)) > now.getTime()) {
			return false;
		}
		
		List<SubRule> timeRule = rule.getSubrules().stream().filter(r -> r instanceof TimeSubRule).collect(Collectors.toList());
		if (!timeRule.isEmpty()) {
			TimeSubRule tr = (TimeSubRule) timeRule.get(0);
			return tr.isActive(new Date(), timezone);
		}
		return true;
	}
	
	public boolean ruleMatches(Date now, Map<String,WeatherData> weatherData) {
		if (!isActive(now)) {
			return false;
		}

		LocationSubRule loc = (LocationSubRule) rule.getSubrules().get(1);
		WeatherData data = weatherData.get(loc.getLocId());
		boolean matches = true;
		for(int i = 3; matches && i < rule.getSubrules().size(); i++) {
			SubRule subrule = rule.getSubrules().get(i);
			if (subrule instanceof LocationSubRule) {
				loc = (LocationSubRule) rule.getSubrules().get(1);
				data = weatherData.get(loc.getLocId());
				continue;
			}
			matches = subrule.ruleMatches(now, timezone, data);
		}
		
		lastNotify.setTime(now.getTime());
		return true;
	}

	public String getUid() {
		return uid;
	}

	public void setUid(String uid) {
		this.uid = uid;
	}

	public String getPushToken() {
		return pushToken;
	}

	public void setPushToken(String pushToken) {
		this.pushToken = pushToken;
	}

	public Rule getRule() {
		return rule;
	}

	public void setRule(Rule rule) {
		this.rule = rule;
	}

	@Access(AccessType.PROPERTY)
	@Column(name="rule", columnDefinition="CLOB")
	public String getJson() {
		try {
			return TO_JSON.writeValueAsString(rule);
		} catch (JsonProcessingException e) {
			log.warn("Unable to serialize to json '{}'", rule, e);
			return null;
		}
	}

	@Access(AccessType.PROPERTY)
	public void setJson(String json) {
		try {
			rule = FROM_JSON.readValue(json);
		} catch (IOException e) {
			log.warn("Unable to parse json '{}'", json, e);
		}
	}

	public String getTz() {
		return tz;
	}

	public void setTz(String tz) {
		this.tz = tz;
		this.timezone = TimeZone.getTimeZone(tz);
	}

	public TimeZone getTimeZone() {
		if (timezone == null) {
			timezone = TimeZone.getTimeZone(tz);
		}
		return timezone;
	}

	public void setTimezone(TimeZone timezone) {
		this.timezone = timezone;
		this.tz = timezone.getID();
	}

	public String getRuleId() {
		return ruleId;
	}

	public void setRuleId(String ruleId) {
		this.ruleId = ruleId;
	}

	public Date getLastNotify() {
		return lastNotify;
	}

	public void setLastNotify(Date lastNotify) {
		this.lastNotify = lastNotify;
	}
	
	public static class RuleId implements Serializable {
		private static final long serialVersionUID = 1L;
		public RuleId() { }
		public RuleId(String uid, String pushToken, String ruleId) {
			this.uid = uid;
			this.pushToken = pushToken;
			this.ruleId = ruleId;
		}
		String uid;
		String pushToken;
		String ruleId;
		@Override
		public int hashCode() {
			final int prime = 31;
			int result = 1;
			result = prime * result + ((pushToken == null) ? 0 : pushToken.hashCode());
			result = prime * result + ((ruleId == null) ? 0 : ruleId.hashCode());
			result = prime * result + ((uid == null) ? 0 : uid.hashCode());
			return result;
		}
		@Override
		public boolean equals(Object obj) {
			if (this == obj)
				return true;
			if (obj == null)
				return false;
			if (getClass() != obj.getClass())
				return false;
			RuleId other = (RuleId) obj;
			if (pushToken == null) {
				if (other.pushToken != null)
					return false;
			} else if (!pushToken.equals(other.pushToken))
				return false;
			if (ruleId == null) {
				if (other.ruleId != null)
					return false;
			} else if (!ruleId.equals(other.ruleId))
				return false;
			if (uid == null) {
				if (other.uid != null)
					return false;
			} else if (!uid.equals(other.uid))
				return false;
			return true;
		}
	}

}
