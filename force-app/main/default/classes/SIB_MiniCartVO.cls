/**
 * Created by junaidmohammed on 10/4/24.
 */

global with sharing class SIB_MiniCartVO {

    global class Request {

        global String identifier;
    }

    global class Response
    {
       @AuraEnabled
        global String Name;

        @AuraEnabled
        global Integer totalProductCount;

        @AuraEnabled
        global Boolean success;

        @AuraEnabled
        global String message;
    }

}