package us.pojo.tempteller.model.rule;

public abstract class SingleValueSubRule extends SubRule {
	private static final double EPSILON = 0.00001;
	private Double value;
	private String op;

	public Double getValue() {
		return value;
	}

	public void setValue(Double value) {
		this.value = value;
	}

	public String getOp() {
		return op;
	}

	public void setOp(String op) {
		this.op = op;
	}
	
	public boolean compare(String op, Double lhs, Double rhs) {
		if ("<".equals(op)) {
			return (rhs - lhs) > EPSILON ;
		} else if ("<=".equals(op)) {
			return (rhs - lhs) > EPSILON || Math.abs(lhs - rhs) < EPSILON;
		} else if (">".equals(op)) {
			return (lhs - rhs) > EPSILON;
		} else if (">=".equals(op)) {
			return (lhs - rhs) > EPSILON || Math.abs(lhs - rhs) < EPSILON;
		} else if ("=".equals(op)) {
			return Math.abs(lhs - rhs) < EPSILON;
		} else {
			return false;
		}
	}
}
