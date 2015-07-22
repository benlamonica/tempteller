package us.pojo.weathernotifier.model;

public abstract class SingleValueSubRule extends SubRule {
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
}
