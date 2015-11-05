package us.pojo.tempteller.model.weather;

public class TemperatureSubRule extends SingleValueSubRule {
	private Boolean isFarenheit;

	public Boolean getIsFarenheit() {
		return isFarenheit;
	}

	public void setIsFarenheit(Boolean isFarenheit) {
		this.isFarenheit = isFarenheit;
	}

	@Override
	public String toString() {
		return "TemperatureSubRule [isFarenheit=" + isFarenheit
				+ ", getValue()=" + getValue() + ", getOp()=" + getOp() + "]";
	}
}
