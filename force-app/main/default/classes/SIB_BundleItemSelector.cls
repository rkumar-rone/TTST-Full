/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-11-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_BundleItemSelector {
    private static final String OBJ_NAME = 'Bundle_Item__c';

    public static Integer getCountByParentId(Id productId) {
        String query = 'SELECT COUNT() FROM Bundle_Item__c WHERE Bundle_Parent_Item__c = :productId';
        return Database.countQuery(query);
    }

    public static List<SObject> getBundleItemsByProductIds(List<Id> productIds){
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM ' + OBJ_NAME + ' ';
        String whereClause = ' WHERE Bundle_Parent_Item__c IN :productIds';
        String limitClause = ' LIMIT 49999';  
        String finalQuery = query + whereClause + limitClause;
        List<SObject> resultList = Database.query(finalQuery);
        return resultList.isEmpty() ? null : resultList;
    }
}