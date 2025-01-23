/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  : 
**/
@isTest
public class SIB_ProductSearchResponseTest {
	@isTest
    static void test(){
        SIB_ProductSearchResponse psr = new SIB_ProductSearchResponse();
        
        SIB_ProductSearchResponse.SearchCategory sc = new SIB_ProductSearchResponse.SearchCategory();
        sc.id = '000000000000000AAA';
        sc.name = 'test';
        sc.urlSlug = 'test';
        sc.description = 'test';
        sc.children = new List<SIB_ProductSearchResponse.SearchCategory>();
        sc.productCount = 1;
        psr.searchCategory = sc;
        
        SIB_ProductSearchResponse.SearchFilter sf = new SIB_ProductSearchResponse.SearchFilter();
        sf.nameOrId = 'test';
        sf.attributeType = 'test';
        sf.displayName = 'test';
        sf.displayRank = 1;
        sf.displayType = 'test';
        sf.facetType = 'test';
        
        SIB_ProductSearchResponse.FilterValue fv = new SIB_ProductSearchResponse.FilterValue();
        fv.displayName = 'test';
        fv.nameOrId = 'test';
        fv.productCount = 1;
        fv.type='test';
        fv.checked = true;
        sf.values = new List<SIB_ProductSearchResponse.FilterValue>{fv};
        
        psr.filters = new List<SIB_ProductSearchResponse.SearchFilter>{sf};
        
        SIB_ProductSearchResponse.SortRule sr = new SIB_ProductSearchResponse.SortRule();
        sr.displayName = 'test';
        sr.nameOrId = 'test';
        sr.sortOrder = 1;
        sr.sortRuleId = 'test';
        
        psr.sortRules = new List<SIB_ProductSearchResponse.SortRule>{sr};
        psr.locale = 'test';
        psr.pageSize = 1;
        psr.total = 1;
        psr.products = new List<SIB_ProductDetail>();
    }
}