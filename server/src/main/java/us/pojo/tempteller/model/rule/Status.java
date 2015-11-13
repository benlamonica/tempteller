package us.pojo.tempteller.model.rule;

import java.io.Serializable;

public class Status implements Serializable {

	private static final long serialVersionUID = 1L;

	private String status;
	
	private String ruleId;
	
	public Status(String ruleId, String status) {
		this.ruleId = ruleId;
		this.status = status;
	}
	
	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public String getStatus() {
		return status;
	}

	public String getRuleId() {
		return ruleId;
	}

	public void setRuleId(String ruleId) {
		this.ruleId = ruleId;
	}

	public void setStatus(String status) {
		this.status = status;
	}
}
