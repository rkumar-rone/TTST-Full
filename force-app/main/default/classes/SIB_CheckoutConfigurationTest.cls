/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 10-16-2024
 * @last modified by  : 
**/
@isTest
public class SIB_CheckoutConfigurationTest {
	@isTest
    static void test(){
        SIB_CheckoutConfiguration cc = new SIB_CheckoutConfiguration();
        cc.id='test';
        cc.displayLayout = 'test';
        cc.availablePaymentMethods = new List<String>();
        cc.creditCardGateway = 'test';
        cc.creditCardGatewayClassMap = new Map<String,String>();
        cc.isShippingProviderEnabled = 'test';
        cc.shippingProvider = new List<String>();
        cc.isTaxProviderEnabled = 'test';
        cc.taxProvider = 'test';
        cc.allowPromoCode = true;
        SIB_CheckoutConfiguration response = SIB_CheckoutConfiguration.parse('{"id":"test"}');
    }
}