package us.pojo.tempteller.service.notify;

import com.lmax.disruptor.EventFactory;

import us.pojo.tempteller.model.rule.NotifiableRule;

public class WeatherNotificationEvent {
	private NotifiableRule rule;
	
	public void setRule(NotifiableRule rule) {
		this.rule = rule;
	}
	
	
	
	public static class Factory implements EventFactory<WeatherNotificationEvent> {
		@Override
		public WeatherNotificationEvent newInstance() {
			return new WeatherNotificationEvent();
		}
	}
}
