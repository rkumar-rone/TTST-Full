/**
 * @description       : Selector Class for SIB_Course_Review__c
 * @author            : Gaurang Arora
 * @last modified on  : 
 * @last modified by  : 
**/
public without sharing class SIB_CourseReviewSelector {
    private static final String OBJ_NAME = 'SIB_Course_Review__c';

    public static List<Sobject> getReviewsByCourseId(List<Id> courseIds, Boolean forBatch) {
        String size = '10000'; //Default size
        List<String> metadataRecords = SIB_Util.fetchConfigByModule(SIB_Constants.PDP_LIMIT_MODULE);
        if(!metadataRecords.isEmpty() && !forBatch){
            size = metadataRecords[0];
        }
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ',Course__r.Name'  +' FROM '+ OBJ_NAME + ' ';
        String whereClause = ' WHERE Course__c IN :courseIds';
        String orderByClause = ' ORDER BY Date__c DESC';
        String limitClause = ' LIMIT ' + size;  
        String courseQuery = query + whereClause + orderByClause + limitClause;
        List<SObject> resultList = Database.query(courseQuery);
        return resultList;
    }

    public static Decimal getAggregateAvg(String CourseId){
        String query = 'SELECT AVG(Rating__c) avgValue FROM SIB_Course_Review__c WHERE Course__c =: CourseId';
        List<SObject> resultList = Database.query(query);
        return (Decimal)resultList[0].get('avgValue');
    }

    public static Integer getAggregateCount(String CourseId){
        String query = 'SELECT COUNT(Id) totalValue FROM SIB_Course_Review__c WHERE Course__c =: CourseId';
        List<SObject> resultList = Database.query(query);
        return (Integer)resultList[0].get('totalValue');    
    }
}