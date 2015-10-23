package us.pojo.tempteller.model;

import java.util.ArrayList;

public class ConditionSubRule extends SubRule {
	private ArrayList<String> conditions;
	private String op;	
	
	public ArrayList<String> getConditions() {
		return conditions;
	}

	public String getOp() {
		return op;
	}

	public void setConditions(ArrayList<String> conditions) {
		this.conditions = conditions;
	}

	public void setOp(String op) {
		this.op = op;
	}

	@Override
	public String toString() {
		return "ConditionSubRule [conditions=" + conditions + ", op=" + op + "]";
	}

}
