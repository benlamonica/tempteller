package us.pojo.tempteller.model.auth;

import java.text.SimpleDateFormat;
import static org.junit.Assert.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Test;

public class ReceiptTest {

	private SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");

	private List<Map<String,String>> createReceiptMap(String ... dateProducts) {
		List<Map<String,String>> receipt = new ArrayList<>();
		for (int i = 0; i < dateProducts.length; i += 2) {
			Map<String,String> purchase = new HashMap<>();
			purchase.put("purchase-date", dateProducts[i]);
			purchase.put("product-id", dateProducts[i+1]);
			receipt.add(purchase);
		}
		
		return receipt;
	}
	
	@Test
	public void shouldGrantUserExtraWeekForTheFirstTransaction() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month"));
		assertEquals("2015-12-21", df.format(target.getSubEndDate()));
	}
	
	@Test
	public void shouldStartSubscriptionFromTransactionDateIfPriorTransactionHasLapsed() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month", "2016-01-01", "1_Month"));
		assertEquals("2016-02-01", df.format(target.getSubEndDate()));	
	}
	
	@Test
	public void shouldAddSixMonthsToEndDateFor6_MonthProduct() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month", "2016-01-01", "6_Month"));
		assertEquals("2016-07-01", df.format(target.getSubEndDate()));	
	}
		
	@Test
	public void shouldAddTwelveMonthToEndDateFor1_YearProduct() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month", "2016-01-01", "12_Month"));
		assertEquals("2017-01-01", df.format(target.getSubEndDate()));	
	}
	
	@Test
	public void shouldExtendExistingSubscription() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month", "2015-12-01", "1_Month"));
		assertEquals("2016-01-21", df.format(target.getSubEndDate()));			
	}
	
	@Test
	public void shouldNotExtendSubscriptionIfProductIsUnknown() {
		Receipt target = new Receipt(createReceiptMap("2015-11-14", "1_Month", "2015-12-01", "2_Month"));
		assertEquals("2015-12-21", df.format(target.getSubEndDate()));			
	}
	
	@Test
	public void shouldNotExtendSubscriptionIfDateIsUnparseable() {
		Receipt target = new Receipt(createReceiptMap("20151114", "1_Month"));
		assertNull(target.getSubEndDate());			
	}

}
