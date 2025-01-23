/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 05-15-2024
 * @last modified by  : Jassimran Virdi
**/
public with sharing class SIB_CartItemSelector {
    
    private static final String CLASSNAME = 'SIB_CartItemSelector';
    private static final String OBJ_NAME = 'CartItem';

    public static Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'SKU',
            'Type',
            'TotalPriceAfterAllAdjustments',
            'Quantity',
            'Product2.Name',
            'Product2.StockKeepingUnit',
            'Product2.Delivery_Format__c',
            'Product2.Product_Group__c',
            'Product2.In_Person_Tax_Code__c',
            'Product2.Virtual_Tax_Code__c',
            'Product2.Training_Location_Street_formula__c',
            'Product2.Training_Location_City_formula__c',
            'Product2.Training_Location_State_formula__c',
            'Product2.Training_Location_Country_formula__c',
            'Product2.Training_Location_Zip_Code_formula__c',
            'CartDeliveryGroup.DeliverToStreet',
            'CartDeliveryGroup.DeliverToCity',
            'CartDeliveryGroup.DeliverToState',
            'CartDeliveryGroup.DeliverToPostalCode',
            'CartDeliveryGroup.DeliverToCountry',
            'Cart.BillingStreet',
            'Cart.BillingCity',
            'Cart.BillingState',
            'Cart.BillingCountry',
            'Cart.BillingPostalCode'
        };
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }

    public static List<Sobject> getCartItemsByCartIds(List<Id> cartIds) {
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE cartId IN :cartIds ';
        String orderByClause = ' ORDER BY Name LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }
}