/**
 * @description         : Querys for frequentlyQuestions component
 * @author              : David Sanchez
 * @last modified on    : 15-09-2023
 * @last modified by    : David Sanchez
 */
public with sharing class FrequentlyQuestions {
    /**
    * @description Gets all custom metadata fields for the frequentlyQuestions component
    * @param request the list of custom metadata fields records that need to be handled in the frequentlyQuestions component
    * @return the list of frequently questoins records that need to be shown
    */
    @AuraEnabled(cacheable=true)
    public static List<TTS_Store_FAQ__mdt> getFrequentlyQuestions() {

        List<TTS_Store_FAQ__mdt> questionsList = [
            SELECT Id, Question__c, Answer__c, Answer_List__c, Category__c
            FROM TTS_Store_FAQ__mdt
        ];
        
        return questionsList;
    }
}