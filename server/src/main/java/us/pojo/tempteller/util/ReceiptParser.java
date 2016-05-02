package us.pojo.tempteller.util;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.Security;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.bouncycastle.asn1.ASN1Encodable;
import org.bouncycastle.asn1.ASN1InputStream;
import org.bouncycastle.asn1.ASN1Integer;
import org.bouncycastle.asn1.ASN1OctetString;
import org.bouncycastle.asn1.ASN1Primitive;
import org.bouncycastle.asn1.ASN1Set;
import org.bouncycastle.asn1.DERIA5String;
import org.bouncycastle.asn1.DERUTF8String;
import org.bouncycastle.asn1.DLSequence;
import org.bouncycastle.asn1.cms.ContentInfo;
import org.bouncycastle.cms.CMSException;
import org.bouncycastle.cms.CMSSignedData;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ClassPathResource;
import org.springframework.ws.soap.security.support.KeyStoreFactoryBean;

public class ReceiptParser {

	private Logger log = LoggerFactory.getLogger(ReceiptParser.class);

	// Move keystore stuff into Spring file
	private static final String APPLE_TRUSTSTORE_PW = "8rLLtGnyRgYizCRC4YpY";

	private static KeyStore getKeyStore() throws RuntimeException {
		KeyStoreFactoryBean ksf = new KeyStoreFactoryBean();
		ksf.setLocation(new ClassPathResource("/AppleCA.jks"));
		ksf.setPassword(APPLE_TRUSTSTORE_PW);
		try {
			ksf.afterPropertiesSet();
		} catch (GeneralSecurityException | IOException e) {
			throw new RuntimeException("Problem getting keystore.", e);
		}
		return ksf.getObject();
	}

	private KeyStore appleCA = getKeyStore();

	static {
		Security.addProvider(new BouncyCastleProvider());
	}

	private BigInteger getInt(ASN1Encodable f) {
		if (f instanceof ASN1Integer) {
			return ((ASN1Integer) f).getValue();
		}

		return null;
	}

	private String getString(ASN1Encodable f) {
		ASN1Primitive fieldValue;
		if (f instanceof ASN1OctetString) {
			try {
				fieldValue = ASN1Primitive.fromByteArray(((ASN1OctetString) f).getOctets());
			} catch (IOException e) {
				log.warn("Unable to deserialize value for ASN1 field '{}'", f);
				return null;
			}
		} else {
			log.warn("Expected an ASN1OctetString as field value '{}'", f);
			return null;
		}

		String val = null;
		if (fieldValue instanceof DERUTF8String) {
			val = ((DERUTF8String) fieldValue).getString();
		} else if (fieldValue instanceof ASN1Integer) {
			val = ((ASN1Integer) fieldValue).getValue().toString();
		} else if (fieldValue instanceof DERIA5String) {
			val = ((DERIA5String) fieldValue).getString();
		} else {
			log.warn("Field was not an expected type");
		}

		return val;
	}

	private ASN1Set getSet(ASN1Encodable f) {
		if (f instanceof ASN1OctetString) {
			try {
				return (ASN1Set) ASN1Primitive.fromByteArray(((ASN1OctetString) f).getOctets());
			} catch (IOException e) {
				log.warn("Unable to get the ASN1Set '{}'", f);
				return null;
			}
		} else {
			log.warn("Unable to parse the ASN1Set '{}'", f);
			return null;
		}
	}

	/**
	 * It gets a DLSequence representing a field of the purchase record, then
	 * parse and return it as a Map
	 *
	 * The DLSequence is something like:
	 *
	 * [1704, 1, #1614323031342d30322d31395431333a32363a35345a]
	 *
	 * where the first element is the field type, the second is the version and
	 * the third is the asn1 encoded value
	 *
	 * @param field
	 *            the DLSequence representing a purchase field
	 * @return a Map representing the parsed input field
	 */
	private void parsePurchaseField(DLSequence field, Map<String, String> purchase) {
		// get the field type as a plain integer
		BigInteger fieldType = getInt(field.getObjectAt(0));
		String fieldVal = getString(field.getObjectAt(2));

		// construct the Map according the field type
		switch (fieldType.intValue()) {
		case 1701:
			purchase.put("quantity", fieldVal);
			break;
		case 1702:
			purchase.put("product-id", fieldVal);
			break;
		case 1703:
			purchase.put("transaction-id", fieldVal);
			break;
		case 1704:
			purchase.put("purchase-date", fieldVal);
			break;
		case 1705:
			purchase.put("org-transaction-id", fieldVal);
			break;
		case 1706:
			purchase.put("org-purchase-date", fieldVal);
			break;
		case 1708:
			purchase.put("subscription-exp-date", fieldVal);
			break;
		case 1712:
			purchase.put("cancellation-date", fieldVal);
			break;
		default:
			purchase.put(String.valueOf(fieldType), fieldVal);
			break;
		}
	}

	/**
	 * It gets a DLSequence representing a purchase and parses it.
	 *
	 * The DLSequence is something like this:
	 *
	 * [17, 1, #3182014b300b020206.....]
	 *
	 * where the first element is the field type (always 17 for purchase
	 * record), the second is the version and the third is the asn1 encoded set
	 * (of purchase fields)
	 *
	 * @param purchase
	 *            the DLSequence representing the purchase
	 * @return a Map containing all the fields of the input purchase record
	 */
	@SuppressWarnings("unchecked")
	private Map<String, String> parsePurchase(DLSequence purchase) {
		// get the asn1 representation of the purchase record
		ASN1Set fieldSet = getSet(purchase.getObjectAt(2));

		if (fieldSet != null) {
			// get the iterator on the fields of the set
			Map<String, String> parsedPurchase = new HashMap<>();
			for (DLSequence inAppPurchase : Collections.list((Enumeration<DLSequence>) fieldSet.getObjects())) {
				parsePurchaseField(inAppPurchase, parsedPurchase);
			}

			return parsedPurchase;
		} else {
			return null;
		}
	}

	/**
	 * It gets a DLSequence representing a receipt record and check if it is
	 * purchase record.
	 *
	 * The DLSequence is something like this:
	 *
	 * [17, 1, #3182014b300b020206.....]
	 *
	 * where the first element is the field type (always 17 for purchase
	 * record), the second is the version and the third is the asn1 encoded set
	 * (of purchase fields)
	 *
	 * @param maybePurchase
	 * @return true if the input is a purchase record
	 */
	private boolean isPurchase(DLSequence maybePurchase) {
		// get the record type as a simple integer
		BigInteger recordType = getInt(maybePurchase.getObjectAt(0));
		return recordType != null && recordType.intValue() == 17;
	}

	@SuppressWarnings("unchecked")
	private List<DLSequence> getContentIterator(CMSSignedData signedData) throws IOException {
		// retrieve the byte array of the signed content and create a
		// ASN1Primitive generic object out of it
		ASN1Set asn1Set = (ASN1Set) ASN1Primitive.fromByteArray((byte[]) signedData.getSignedContent().getContent());
		return Collections.list(asn1Set.getObjects());
	}

	/**
	 * Get the signed data object from the receipt
	 *
	 * @param stream
	 *            the stream from where to read the signed data
	 * @return the signed data object
	 */
	private CMSSignedData getSignedData(InputStream stream) throws CMSException, IOException {

		// create an asn1 stream
		ASN1InputStream asn1Stream = null;
		try {
			asn1Stream = new ASN1InputStream(stream);

			// read object from asn1 stream and create the content info out of
			// it
			ContentInfo contentInfo = ContentInfo.getInstance(asn1Stream.readObject());

			// create the cms signed data object out of content info object
			return new CMSSignedData(contentInfo);
		} finally {
			if (asn1Stream != null) {
				asn1Stream.close();
			}
		}
	}

	/**
	 * The signed data of a in-app purchase would be an asn1 encoded list of
	 * DLSequence's. This method return an Iterator on the set of DLSequence's
	 * of the receipt
	 *
	 * @param signedData
	 *            the signed data from the receipt
	 * @return the iterator on the set of DLSequences of the receipt
	 */
	private ASN1Set getReceipt(CMSSignedData signedData) {

		// retrieve the byte array of the signed content and create a
		// ASN1Primitive generic object out of it
		Object data = signedData.getSignedContent().getContent();
		ASN1Set asn1Set = null;
		if (data instanceof byte[]) {
			try {
				asn1Set = (ASN1Set) ASN1Primitive.fromByteArray((byte[]) signedData.getSignedContent().getContent());
			} catch (IOException e) {
				log.warn("Unable to get ASN1Set from content");
				return null;
			}
		} else {
			log.warn("Unable to parse ASN1Set from content");
			return null;
		}

		return asn1Set;
	}

	/**
	 *
	 * The entry point of the receipt parser. It gets an url to the receipt
	 and
	 * return a list of maps, one map for every purchase.
	 *
	 * Example for a map representing a single purchase:
	 *
	 * Map(transaction-id -> 1000000101874971,
	 * purchase-date -> 2014-02-19T13:26:54Z,
	 * org-transaction-id -> 1000000101874971,
	 * quantity -> 1, cancellation-date -> ,
	 * subscription-exp-date -> ,
	 * product-id -> 1_month_subscription,
	 * org-purchase-date -> 2014-02-18T16:18:09Z)
	 * @param deviceId  - used for receipt validation
	 *
	 *
	 * @param receiptUrl the url of the receipt
	 * @return the List of purchases or Failure
	 * @throws CMSException 
	 * @throws IOException 
	 */
	 public List<Map<String,String>> parsePurchases(byte[] data, String deviceId) throws CMSException, IOException {
		 CMSSignedData signedData = new CMSSignedData(data);
		 List<DLSequence> content = getContentIterator(signedData);
		 return content.stream()
				 .filter(o -> isPurchase(o))
				 .map(p -> parsePurchase(p))
				 .collect(Collectors.toList());
	 }
}
