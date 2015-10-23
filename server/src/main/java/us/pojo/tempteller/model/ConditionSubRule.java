package us.pojo.tempteller.model;

import java.util.ArrayList;

public class ConditionSubRule extends SubRule {
	private ArrayList<String> conditions;

	public ArrayList<String> getConditions() {
		return conditions;
	}

	public void setConditions(ArrayList<String> conditions) {
		this.conditions = conditions;
	}

	@Override
	public String toString() {
		return "ConditionSubRule [conditions=" + conditions + "]";
	}

}
