package us.pojo.tempteller.model.rule;

import java.util.Date;
import java.util.TimeZone;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonSubTypes.Type;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

@JsonTypeInfo(  
	    use = JsonTypeInfo.Id.NAME,  
	    include = JsonTypeInfo.As.PROPERTY,  
	    property = "type")  
	@JsonSubTypes({  
	    @Type(value = TemperatureSubRule.class, name = "TemperatureSubRule"),
	    @Type(value = ForecastTempSubRule.class, name="ForecastTempSubRule"),
	    @Type(value = ConditionSubRule.class, name="ConditionSubRule"),
	    @Type(value = ForecastConditionSubRule.class, name="ForecastConditionSubRule"),
	    @Type(value = LocationSubRule.class, name="LocationSubRule"),
	    @Type(value = HumiditySubRule.class, name="HumiditySubRule"),
	    @Type(value = TimeSubRule.class, name="TimeSubRule"),
	    @Type(value = WindSpeedSubRule.class, name="WindSpeedSubRule"),
	    @Type(value = MessageSubRule.class, name="MessageSubRule")
	})  
public abstract class SubRule {
	private String type;

	public abstract boolean ruleMatches(Date now, TimeZone tz, WeatherData data);
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		SubRule other = (SubRule) obj;
		if (type == null) {
			if (other.type != null)
				return false;
		} else if (!type.equals(other.type))
			return false;
		return true;
	}

	public String getType() {
		return type;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((type == null) ? 0 : type.hashCode());
		return result;
	}

	public void setType(String type) {
		this.type = type;
	}
	
}
