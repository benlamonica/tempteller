package us.pojo.tempteller.model.weather;

public class WindSpeedSubRule extends SingleValueSubRule {
	private String units;

	public String getUnits() {
		return units;
	}

	public void setUnits(String units) {
		this.units = units;
	}

	@Override
	public String toString() {
		return "WindSpeedSubRule [units=" + units + ", getValue()="
				+ getValue() + ", getOp()=" + getOp() + "]";
	}

}
