package us.pojo.tempteller.transformer;

import java.io.ByteArrayInputStream;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

import us.pojo.tempteller.model.weather.WeatherData;

public class RSStoWeatherDataTransformer {

	private static final Logger log = LoggerFactory.getLogger(RSStoWeatherDataTransformer.class);
	private static final String HUMIDITY = "/rss/channel/atmosphere/@humidity";
	private static final String TEMPERATURE = "/rss/channel/item/condition/@temp";
	
	private DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
	private XPathFactory xPathFactory = XPathFactory.newInstance();
	
	private Double getDouble(String path, XPath xPath, Document xmlDoc) throws XPathExpressionException {
		String str = xPath.compile(path).evaluate(xmlDoc);
		Double dbl = null;
		if (str != null && !str.trim().isEmpty()) {
			dbl = Double.parseDouble(str);
		}
		
		return dbl;
	}
	
	public WeatherData transform(String woeId, String xml) {
		WeatherData result = null;
		try {
		    DocumentBuilder builder = factory.newDocumentBuilder();
		    XPath xPath =  xPathFactory.newXPath();
			Document xmlDocument = builder.parse(new ByteArrayInputStream(xml.getBytes("utf8")));
			Double temp = getDouble(TEMPERATURE, xPath, xmlDocument);
			Double humidity = getDouble(HUMIDITY, xPath, xmlDocument);
			result = new WeatherData(woeId, temp, humidity);
		} catch (Exception e) {
			log.error("Unable to parse xml '{}'", xml, e);
			result = new WeatherData(woeId, null, null);
		}
		
		return result;
	}
}
