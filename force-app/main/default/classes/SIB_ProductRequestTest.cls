/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_ProductRequestTest {
	@isTest
    static void test(){
        SIB_ProductRequest pr = new SIB_ProductRequest('000000000000000AAA',true,true);
        pr.relatedProductIds = new List<Id>{'000000000000000AAA'};
        SIB_ProductRequest pr2 = new SIB_ProductRequest(new List<Id>{'000000000000000AAA'},true,true);
    }
}