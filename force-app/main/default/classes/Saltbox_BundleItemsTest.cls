@isTest(SeeAllData=true)
public class Saltbox_BundleItemsTest {
    
    @isTest 
    static void testGetBundleProducts() {

        // Setup test data
        String communityId = System.Label.Saltbox_Network_ID;
        String hiProduct = System.label.Saltbox_Bundle_Product;

        // Call the method to test
        List<Product2> result = Saltbox_BundleItems.getBundleProducts(communityId, hiProduct);

        // Verify the result
        // System.assertNotEquals(null, result, 'The result should not be null');
    }

    @isTest 
    static void testNoGetProducts() {

        // Setup test data
        String communityId = System.Label.Saltbox_Network_ID;
        String hiProduct = '12345';

        // Call the method to test
        List<Product2> result = Saltbox_BundleItems.getBundleProducts(communityId, hiProduct);

        // Verify the result
        // System.assertEquals(null, result, 'The result should be null');
    }
}