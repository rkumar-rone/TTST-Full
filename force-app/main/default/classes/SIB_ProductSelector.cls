/**
 * @author Anand Reddy
 * @email pareddy@rafter.one
 * @create date 2024-10-14 13:21:15
 * @modify date 2024-10-14 13:21:15
 * @desc [description]
 */

public without sharing class SIB_ProductSelector {
    private static final String CLASSNAME = 'SIB_ProductSelector';
    private static final String OBJ_NAME = 'Product2';

    public static List<Sobject> getProductByIds(List<Id> productIds) {
        Date currentDate = Date.today();
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE Id IN :productIds ';
        String orderQuery = query + whereClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }

    public static List<Sobject> getProductByEventIds(List<Id> eventIds) {
        Date currentDate = Date.today();
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE TTS_Event__c IN :eventIds ';
        String orderQuery = query + whereClause;
        List<SObject> resultList = Database.query(orderQuery);
        return  resultList.isEmpty()?null:resultList;
    }
}