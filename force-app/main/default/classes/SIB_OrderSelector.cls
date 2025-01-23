/**
 * @author Amit Prashar
 * @email aprashar@rafter.one
 * @create date 2024-07-17 13:21:15
 * @modify date 2024-07-17 13:21:15
 * @desc [description]
 */

public with sharing class SIB_OrderSelector {
    private static final String CLASSNAME = 'SIB_OrderSelector';
    private static final String OBJ_NAME = 'Order';

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
            //'TotalProductAmount'
            'TotalAdjustedProductAmount',
            'CartId__c',
            '(SELECT Id, Product2Id, Product2.Name, Product2.StockKeepingUnit, Quantity, ListPrice, UnitPrice, TotalPrice, TotalAdjustmentAmount FROM OrderItems WHERE TypeCode != \'Charge\')',
            '(SELECT Id, DeliverToName, DeliverToStreet, DeliverToCity, DeliverToStateCode, DeliverToPostalCode, DeliverToCountryCode, OrderDeliveryMethod.Name FROM OrderDeliveryGroups)'
        };  
    }

    public static String getQueryFieldString() {
        List<String> queryFieldsList = new List<String>(getDefaultFields());
        return String.join(queryFieldsList, ',');
    }

    public static List<Sobject> getOrderByIds(List<Id> ordIds) {
        Date currentDate = Date.today();
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE Id IN :ordIds ';
        String orderByClause = ' ORDER BY OrderNumber LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }

    public static List<Sobject> getOrderByOrderNumbers(List<String> ordNums) {
        Date currentDate = Date.today();
        String query =' SELECT ' + getQueryFieldString() + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE OrderReferenceNumber IN :ordNums ';
        String orderByClause = ' ORDER BY OrderReferenceNumber LIMIT 49999 ';
        String orderQuery = query + whereClause + orderByClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }
}