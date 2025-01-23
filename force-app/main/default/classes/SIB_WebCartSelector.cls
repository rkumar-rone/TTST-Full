/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_WebCartSelector {
   private static final String OBJ_NAME = 'WebCart';

   public static List<SObject> getCartByIds(List<Id> cartIds){
       String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM ' + OBJ_NAME + ' ';
       String whereClause = ' WHERE Id IN :cartIds';
       String limitClause = ' LIMIT 49999';  
       String finalQuery = query + whereClause + limitClause;
       List<SObject> resultList = Database.query(finalQuery);
       return resultList.isEmpty() ? null : resultList;
   }
}