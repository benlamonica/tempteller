package us.pojo.weathernotifier.model;

public class MessageSubRule extends SubRule {
	private String message;

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	@Override
	public String toString() {
		return "MessageSubRule [message=" + message + "]";
	}

}
