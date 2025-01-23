/**
 * @description       : 
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  : 
**/
@isTest
public class SIB_PLPConfigurationTest {
	@isTest
    static void test(){
        SIB_PLPConfiguration plp = new SIB_PLPConfiguration();
        plp.id = 'test';
        plp.type = 'test';
        plp.cssTheme = 'test';
        plp.showProductImage = true;
        plp.showOriginalPrice = true;
        plp.showNegotiatedPrice = true;
        plp.showLayoutButtons = true;
        plp.showCallToActionButton = true;
        plp.showQuantitySelector = true;
        plp.viewOptionsButtonText = 'test';
        plp.addToCartButtonStyle = 'test';
        plp.addToCartButtonText = 'test';
        plp.addToCartButtonProcessingText = 'test';
        plp.minimumQuantityGuideText = 'test';
        plp.maximumQuantityGuideText = 'test';
        plp.incrementQuantityGuideText = 'test';
        plp.quantitySelectorLabelText = 'test';
        plp.showQuantityRulesText = 'test';
        plp.unavailablePriceText = 'test';
        plp.defaultView = 'test';
        plp.gridMaxColumnsDisplayed = 1;
        plp.searchResultsPageSize = 1;
        plp.selfStudyPageSize = 1;
        plp.pageSize = 1;
        plp.availableLayouts = new List<String>();
        plp.searchResultsFields = new List<String>();
        SIB_PLPConfiguration.CardContentMapping ccm = new SIB_PLPConfiguration.CardContentMapping();
        ccm.showLabel = true;
        ccm.name = 'test';
        ccm.label = 'test';
        plp.cardContentMapping = new List<SIB_PLPConfiguration.CardContentMapping>{ccm};
    }
}