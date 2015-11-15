package us.pojo.tempteller.model.auth;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Receipt {
	private static Logger log = LoggerFactory.getLogger(Receipt.class);
	@SuppressWarnings("serial")
	private static final Map<String,Integer> PRODUCT_MAP = new HashMap<String,Integer>() {{
		put("1_Month", 1);
		put("6_Month", 6);
		put("12_Month", 12);
	}};
	
	private List<Map<String,String>> receipt;
	
	public Receipt(List<Map<String,String>> receipt) {
		this.receipt = receipt;
	}
	
	public Date getSubEndDate() {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		Date endDate = null;
		Calendar cal = Calendar.getInstance();
		for(Map<String,String> purchase : receipt) {
			Integer months = PRODUCT_MAP.get(purchase.get("product-id"));
			if (months == null) {
				log.warn("Could not find product '{}'", purchase.get("product-id"));
				continue;
			}
			
			String date = purchase.getOrDefault("org-purchase-date", purchase.get("purchase-date"));
			try {
				cal.setTime(df.parse(date));
				if (endDate == null) {
					// give the user an extra week, since we have a trial period
					cal.add(Calendar.DATE, 7);
				} else if (endDate.after(cal.getTime())){
					cal.setTime(endDate);;
				}
				cal.add(Calendar.MONTH, months);
				endDate = cal.getTime();
			} catch (Exception e) {
				log.warn("Unable to parse date '{}'", date);
			}
		}
		
		return endDate;
	}

	public List<String> getTxnIds() {
		return receipt.stream()
			.filter(p -> PRODUCT_MAP.containsKey(p.get("product-id")))
			.map(p -> p.getOrDefault("org-transaction-id", p.get("transaction-id")))
			.collect(Collectors.toList());
	}
}
