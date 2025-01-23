/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 08-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_OrderSummarySelector {
    
    private static final String CLASSNAME = 'SIB_OrderSummarySelector';
    private static final String OBJ_NAME = 'OrderSummary';

    public static Set<String> getDefaultFields() {
        return new Set<String>{
            'Id',
            'OrderNumber',
            'OrderedDate',
            'BillingStreet',
            'BillingCity',
            'BillingStateCode',
            'BillingPostalCode',
            'BillingCountryCode',
            'BillingPhoneNumber',
            'Account.BillingStreet',
            'Account.BillingCity', 
            'Account.BillingStateCode', 
            'Account.BillingPostalCode', 
            'Account.BillingCountryCode',
            'Owner.Email',
            'Owner.Name',
            'TotalAdjustedDeliveryAmount',
            'PoNumber',
            'CurrencyIsoCode',
            'GrandTotalAmount',
            'TotalTaxAmount',
            'TotalProductAmount',
            'TotalAdjustedProductAmount',
            'TotalAmount',
            'CartId__c',
            'Payment_Method__c',
            'Account.Name',
            'Status',
            'OriginalOrder.OrderNumber',
            '(SELECT Id, Product2Id, Product2.Name, Product2.StockKeepingUnit, Product2.Product_Group__c, Product2.SIB_SlugUrl__c, Quantity, ListPrice, UnitPrice, TotalPrice, TotalAdjustmentAmount FROM OrderItemSummaries WHERE TypeCode != \'Charge\')',
            '(SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToStateCode, DeliverToPostalCode, DeliverToCountryCode, OrderDeliveryMethod.Name FROM OrderDeliveryGroupSummaries)',
            '(SELECT Id, Method FROM OrderPaymentSummaries)'
        };
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }

    public static List<Sobject> getOrderSummaryByIds(List<Id> ordSumIds) {
        Date currentDate = Date.today();
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE Id IN :ordSumIds ';
        String orderByClause = ' ORDER BY OrderNumber LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }

    public static List<Sobject> getOrderSummaryByOrderNumbers(List<String> ordNums) {
        Date currentDate = Date.today();
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE OrderNumber IN :ordNums ';
        String orderByClause = ' ORDER BY OrderNumber LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }

    public static List<Sobject> getOrderSummaryByOrderReferenceNumbers(List<String> ordNums) {
        Date currentDate = Date.today();
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE OriginalOrder.OrderReferenceNumber IN :ordNums ';
        String orderByClause = ' ORDER BY OrderNumber LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }
}