public without sharing class SIB_RelatedProductsSelector {
    
    private static final String CLASSNAME = 'SIB_RelatedProductsSelector';
    private static final String OBJ_NAME = 'B2B_Recommendation__c';

    public static List<Sobject> getRelatedProductsSelectorByIds(List<Id> productIds) {
        Date currentDate = Date.today();
        String query =' SELECT ' + SIB_Util.getAllObjectFields(OBJ_NAME) + ' FROM '+OBJ_NAME+' ';
        String whereClause =  ' WHERE Type__c = \'Recommendation\' AND Active__c = true AND Attached_Product__c IN :productIds ';
        String orderByClause = ' ORDER BY Order__c LIMIT 49999 ';
        List<SObject> resultList = Database.query(query+whereClause+orderByClause);
        return  resultList;
    }
}