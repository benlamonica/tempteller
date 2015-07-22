package us.pojo.weathernotifier.model;

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

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}
	
}
