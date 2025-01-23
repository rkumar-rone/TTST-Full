/**
 * @description       : Selector class for SIB_AddressHelper
 * @author            : Gaurang Arora
 * @group             : 
 * @last modified on  :
 * @last modified by  :
**/
public with sharing class SIB_AddressSelector {
    private static final String OBJ_NAME = 'ContactPointAddress';

    public static List<Sobject> getAddressesByAccountIdsAndAddressType(List<Id> accountIds, String addressType){
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME)  +' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE ParentId IN :accountIds';
        String additionalCondition='';
        if(String.isNotBlank(addressType)){
            additionalCondition = ' AND AddressType =: addressType';
        }
        String orderByClause = ' ORDER BY LastModifiedDate DESC';
        String limitClause = ' LIMIT 10000';  
        String courseQuery = query + whereClause + additionalCondition + orderByClause + limitClause;
        List<SObject> resultList = Database.query(courseQuery);
        return resultList.isEmpty()?null:resultList;
    }

    public static List<Sobject> getAddressesByAccountIds(List<Id> accountIds){
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME)  +' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE ParentId IN :accountIds';
        String orderByClause = ' ORDER BY LastModifiedDate DESC';
        String limitClause = ' LIMIT 10000';  
        String courseQuery = query + whereClause + orderByClause + limitClause;
        List<SObject> resultList = Database.query(courseQuery);
        return resultList.isEmpty()?null:resultList;
    }
}