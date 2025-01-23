/**
 * @description       : 
 * @author            : garora@rafter.one
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
@isTest
public class SIB_PDPConfigurationTest {
	@isTest
    static void test(){
        SIB_PDPConfiguration pdp = new SIB_PDPConfiguration();
        pdp.id='';
        pdp.type='test';
        pdp.cssTheme = 'test';
        pdp.customPDP = 'test';
        SIB_PDPConfiguration.ProductType pt = new SIB_PDPConfiguration.ProductType();
        pt.productType = 'test';
        pt.shortDescriptionField = 'test';
        SIB_PDPConfiguration.TierConfiguration tc = new SIB_PDPConfiguration.TierConfiguration();
        tc.displayType = 'test';
        pt.tierPricingConfig = tc;
        pt.displayPromotionalPrice = true;
        pt.displayPageSections = true;
        pt.pageSectionStyle = 'test';
        SIB_PDPConfiguration.PageSection ps = new SIB_PDPConfiguration.PageSection();
        ps.apiName = 'test';
        ps.title = 'test';
        ps.showOnlyWhenApplicable = true;
        ps.fieldAPIName = 'test';
        pt.pageSections = new List<SIB_PDPConfiguration.PageSection>{ps};
        SIB_PDPConfiguration.RelatedProductType rpt = new SIB_PDPConfiguration.RelatedProductType();
        rpt.apiName = 'test';
        rpt.displayName = 'test';
        rpt.language = 'test';
        pt.relatedProductTypes = new List<SIB_PDPConfiguration.RelatedProductType>{rpt};
        pdp.productTypeList = new List<SIB_PDPConfiguration.ProductType>{pt};
    }
}