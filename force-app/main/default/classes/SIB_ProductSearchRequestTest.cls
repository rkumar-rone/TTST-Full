/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class SIB_ProductSearchRequestTest {
	@isTest
    static void test(){
        SIB_ProductSearchRequest psr = new SIB_ProductSearchRequest();
        psr.categoryId = 'test';
        psr.catalogId = 'test';
        psr.includePrices = true;
        psr.page = 1;
        psr.pageSize = 1;
        psr.searchTerm = 'test';
        psr.sortRuleId = 'test';
        SIB_ProductSearchRequest.RefinementInput ri = new SIB_ProductSearchRequest.RefinementInput();
        ri.nameOrId = 'test';
        ri.attributeType = 'test';
        ri.values = new List<String>();
        psr.refinements = new List<SIB_ProductSearchRequest.RefinementInput>{ri};
    }
}