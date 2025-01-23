@IsTest 
public with sharing class TTSEventRichTextControllerTest {

    @IsTest
    static void setImages(){
        SObject sObj = Saltbox_TestDataFactory.createSObject('Account', false);
        Contentversion cv = new Contentversion();

        cv.Title = 'ABC';
        
        cv.PathOnClient = 'test';
        
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        
        insert cv;
    }

    @IsTest
    static void getTTSEventRichTextTest(){
        SObject sObj = Saltbox_TestDataFactory.createSObject('Campaign', false);
        TTSEventRichTextController.getTTSEventRichText(sObj.Id);
        System.assertNotEquals(null, sObj);
    }
}