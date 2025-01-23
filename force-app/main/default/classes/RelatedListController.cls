/**
 * @description       : Class used to retrieve data based on the columns and other lwc configuration. 
 * @author            : Emmanuel Pech
 * @last modified on  : 12-05-2023
 * @last modified by  : Emmanuel Pech
**/
public with sharing class RelatedListController {
    public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';
    public static final String REMOVED_FIELDS = 'removedFields';
    public static final String SEARCH_KEY = 'searchKey';
    public static final String SEARCH_LIST = 'searchFieldList';
    public static final String RELATED_LIST = 'relatedlist';

    /**
     * @description       : Initialize the data setup based on the configuration properties.
     * @param             : String jsonData receives the lwc configuration as JSON.
     * @return            : String
    **/
    @AuraEnabled
    public static String initData(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        Map<String,Set<String>> removedFields = validateStrings( (List<Sobject>)responseMap.get(RECORDS_PARAM));
        responseMap.put(REMOVED_FIELDS, removedFields);
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId;
        if(requestMap.get(RECORD_ID_PARAM) != ''){
            recordId = (String)requestMap.get(RECORD_ID_PARAM);
        }
        String relatedFieldApiName;
        if(requestMap.get(RELATED_FIELD_API_NAME_PARAM) != ''){
            relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        }
        if(requestMap.get(RECORD_ID_PARAM) != '' && requestMap.get(RELATED_FIELD_API_NAME_PARAM) != ''){
            responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));
        }

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
    /**
     * @description       : Initialize the data setup based on the configuration properties.
     * @param             : String jsonData receives the lwc configuration as JSON.
     * @return            : List<Sobject>
    **/
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId;
        if(root.get(RECORD_ID_PARAM) != ''){
            recordId = (String)root.get(RECORD_ID_PARAM);
        }
        String searchKey = (String)root.get(SEARCH_KEY);
        String searchlist = (String)root.get(SEARCH_LIST);
        Boolean relatedlist = (Boolean)root.get(RELATED_LIST);
        searchKey = searchKey !=null ? searchKey.trim() : '';
        String key = '%' + searchKey + '%';
        String relatedFieldApiName;

        if(root.get(RELATED_FIELD_API_NAME_PARAM) != ''){
            relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
        }

		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);        
        
        String query = 'Select '+fields+' From '+sobjectApiName;

        if(relatedlist){
            query += ' WHERE ' +relatedFieldApiName+ '= :recordId ';
        }

        if(!String.isBlank(searchKey)){
            Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
            Map<String, SObjectField> fieldFullList = sobjectType.getDescribe().fields.getMap();
            List<String> searchFields = searchlist.split(',');
            String likeVarList = '';
            Integer lastItem = searchFields.size() - 1;
            for (Integer i = 0; i < searchFields.size(); i++) {
                String fielHelperVar = searchFields.get(i).trim();

                if(!fielHelperVar.contains('.')){

                    if(fieldFullList.get(fielHelperVar).getDescribe().isAccessible()){
                        likeVarList += searchFields.get(i) + ' LIKE :key OR ';
                        
                    }
                } else {
                    likeVarList += searchFields.get(i) + ' LIKE :key OR ';
                }

                if(i == lastItem){
                    likeVarList = likeVarList.Substring(0,likeVarList.length()-3);
                }

            }
            
            if(relatedlist){
                query += ' AND (' + likeVarList + ')';
            } else {
                query += ' WHERE ' + likeVarList + ' ';

            }

        }
        query += ' ORDER BY ' +orderBy+' Limit :numberOfRecords';
        return Database.query(String.escapeSingleQuotes(query));
	} 

    /**
     * @description       : Remove fields if the user does not have access.
     * @param             : List<Sobject> results receives the objects result
     * @return            : Map<String,Set<String>>
    **/
    public static Map<String,Set<String>> validateStrings(List<Sobject> results){
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, results);
        List<String> removedFields = new List<String>();
        Map<String,Set<String>> removedFieldsList = securityDecision.getRemovedFields();
        return removedFieldsList;
                
    }

    /**
     * @description       : Retrieve the relationship name
     * @param             : Id recordId
     * @param             : String childSobjectApiName
     * @param             : String relatedFieldApiName
     * @return            : String
    **/
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }     
        return name;
    }      
    
    /**
     * @description       : Retrieve the object icon name 
     * @param             : String sobjectApiName
     * @return            : String
    **/
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }  
    
    /**
     * @description       : Check if the record is a group order 
     * @param             : String recordId
     * @return            : Boolean
    **/
    @AuraEnabled
    public static Boolean isGroupOrder(String recordId){

        return [SELECT Order_Type__c FROM OrderSummary WHERE Id = :recordId LIMIT 1].Order_Type__c == 'Group Order';

    }
    
}