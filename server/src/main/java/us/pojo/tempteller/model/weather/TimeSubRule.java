package us.pojo.tempteller.model.weather;

public class TimeSubRule extends SubRule {
	public static class TimeRange {
		public String min;
		public String max;
		@Override
		public String toString() {
			return "TimeRange [min=" + min + ", max=" + max + "]";
		}
	}

	private TimeRange timeRange;
	private String op;

	public TimeRange getTimeRange() {
		return timeRange;
	}

	public void setTimeRange(TimeRange timeRange) {
		this.timeRange = timeRange;
	}

	public String getOp() {
		return op;
	}

	public void setOp(String op) {
		this.op = op;
	}

	@Override
	public String toString() {
		return "TimeSubRule [timeRange=" + timeRange + ", op=" + op + "]";
	}

}