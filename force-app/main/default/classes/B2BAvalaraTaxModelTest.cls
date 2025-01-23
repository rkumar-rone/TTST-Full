/**
 * @description       : Test class for B2BAvalaraTaxModel
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
private class B2BAvalaraTaxModelTest {
    
    @isTest
    static void testB2BAvalaraTaxModelProperties() {        
        B2BAvalaraTaxModel taxModel = new B2BAvalaraTaxModel();
        taxModel.taxAmount = 25.50;
        taxModel.taxRate = 7.5;
        System.assertEquals(25.50, taxModel.taxAmount, 'Tax amount should match the expected value');
        System.assertEquals(7.5, taxModel.taxRate, 'Tax rate should match the expected value');
    }
}