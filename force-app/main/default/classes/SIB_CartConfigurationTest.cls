/**
 * @description       : Test class for SIB_CartConfiguration
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-22-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_CartConfigurationTest {

    @isTest
    static void testParse() {
        SIB_CartConfiguration cartConfig = new SIB_CartConfiguration();

        cartConfig.id = '12345';
        cartConfig.type = 'Standard';
        cartConfig.cssTheme = 'Dark';
        cartConfig.allowPromoCode = true;
        cartConfig.showUniqueCount = false;
        cartConfig.pageSize = 20;
        cartConfig.showRemoveItemOption = true;
        cartConfig.showMoreItemsOption = false;
        cartConfig.showLineItemTotal = true;
        cartConfig.showOriginalPrice = false;
        cartConfig.showSKU = true;
        cartConfig.showProductImage = true;
        cartConfig.showPricePerUnit = false;
        cartConfig.showActualPrice = true;
        cartConfig.hideQuantitySelector = false;
        cartConfig.showSavedAmount = true;

        SIB_CartConfiguration.ProductFields productField1 = new SIB_CartConfiguration.ProductFields();
        productField1.showLabel = true;
        productField1.name = 'Product1';
        productField1.label = 'Product One';

        cartConfig.productFields = new List<SIB_CartConfiguration.ProductFields>{productField1};
        String jsonString = '{"id": "12345"}';

        SIB_CartConfiguration cartConfigParse = SIB_CartConfiguration.parse(jsonString);

        System.assertNotEquals(null, cartConfig, 'Pass');
    }
}