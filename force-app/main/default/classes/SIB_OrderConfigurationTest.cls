/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_OrderConfigurationTest {
	@isTest
    static void test(){
        Test.startTest();
        SIB_OrderConfiguration oc = SIB_OrderConfiguration.parse('{"id":"000000000000000AAA","cssTheme":"test","pageType":"test","objectApiName":"test"}');
        oc.id= '000000000000000AAA';
        oc.cssTheme = 'test';
        oc.pageType = 'test';
        oc.objectApiName = 'test';
        Test.stopTest();
    }
}