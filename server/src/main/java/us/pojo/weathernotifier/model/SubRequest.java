package us.pojo.weathernotifier.model;

import java.io.Serializable;
import java.util.ArrayList;

public class SubRequest implements Serializable {
	private static final long serialVersionUID = 1L;
	private ArrayList<Rule> rules = new ArrayList<Rule>();
	private UserId userId;

	public ArrayList<Rule> getRules() {
		return rules;
	}

	public void setRules(ArrayList<Rule> rules) {
		this.rules = rules;
	}

	public UserId getUserId() {
		return userId;
	}

	public void setUserId(UserId id) {
		this.userId = id;
	}
}
