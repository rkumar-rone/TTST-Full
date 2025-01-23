@isTest
public class EventMgrControllerTest {
    @testSetup public static void TestData() {
        RecordType RT = [select Id,SobjectType from recordtype where SobjectType = 'Campaign' and developername = 'Corporate_Event'];
        RecordType ESRT = [select Id,SobjectType from recordtype where SobjectType = 'Event_Schedule__c' and developername = 'Corporate_Event'];
        RecordType ESRT1 = [select Id,SobjectType from recordtype where SobjectType = 'Event_Schedule__c' and developername = 'Academic_Event_Salesforce_Registration'];
        RecordType ESRT2 = [select Id,SobjectType from recordtype where SobjectType = 'Event_Schedule__c' and developername = 'Academic_Event_Client_Registration'];
        
        //Schedule__c Sch = new Schedule__c(name = 'Test Timeline');
        //insert Sch;
        //System.assert(Sch.Id != null);
        
        Date DD = Date.Today();
        Event_Schedule__c ES = new Event_Schedule__c(Recordtypeid=ESRT.Id, name='Test Schedule',Earliest_Date_Time__c=System.today(),Training_Confirmed__c=DD,Earliest_Date_Time_Detail__c = 'Test Detail',
                                                     Resource_Assignment_Due__c=DD, Contact_Client_POC__c=DD, Setup_in_Accounting__c=DD, Finalize_TA_Staffing__c=DD
                                                    );
        insert ES;
        
        Event_Schedule__c ES1 = new Event_Schedule__c(Recordtypeid=ESRT.Id, name='Test Schedule1',Earliest_Date_Time__c=System.today(),Training_Confirmed__c=DD,Earliest_Date_Time_Detail__c = 'Test Detail',
                                                     Resource_Assignment_Due__c=DD, Contact_Client_POC__c=DD, Setup_in_Accounting__c=DD, Finalize_TA_Staffing__c=DD
                                                    );
        insert ES1;
        
        System.assert(ES1.Id != null);
        
        Event_Schedule__c ES2 = new Event_Schedule__c(Recordtypeid=ESRT1.Id, name='Test Schedule1',Earliest_Date_Time__c=System.today(),Training_Confirmed__c=DD,Earliest_Date_Time_Detail__c = 'Test Detail',
                                                     Resource_Assignment_Due__c=DD, Contact_Client_POC__c=DD, Setup_in_Accounting__c=DD, Finalize_TA_Staffing__c=DD
                                                    );
        insert ES2;
        
        System.assert(ES2.Id != null);
        
        Event_Schedule__c ES3 = new Event_Schedule__c(Recordtypeid=ESRT2.Id, name='Test Schedule1',Earliest_Date_Time__c=System.today(),Training_Confirmed__c=DD,Earliest_Date_Time_Detail__c = 'Test Detail',
                                                     Resource_Assignment_Due__c=DD, Contact_Client_POC__c=DD, Setup_in_Accounting__c=DD, Finalize_TA_Staffing__c=DD
                                                    );
        insert ES3;
        
        System.assert(ES3.Id != null);
                
        Campaign Cam = new Campaign(Recordtypeid = RT.Id, name = 'Test Event', Number_of_TA_s_Requested__c = '2',Self_study_Format__c = 'Physical',Event_Schedule__c=ES.Id);
        insert Cam;
        System.assert(Cam.Id != null);
    }
    
    public static testMethod void TestConstructor()
    {
        for(Event_Schedule__c ES : [select Id, Name, ownerId, Days__c, Start_Date__c, End_Date__c, recordtype.name,
                    LOA_SOW_Signed__c, LOA_SOW_Sent__c, Resource_Assignment_Due__c, Books_Received_by_Client__c,Expenses_Submitted__c, Timeline_Planning_Call_Complete__c,
                    Resource_Assigned__c, Contact_Client_POC__c, Sign_In_Sheet_Received__c,Training_Recap_Complete__c, TA_Staffing_Complete__c, Book_Order_Placed__c, Case_Study_Pre_reading_Opened_Delivered__c,
                    Send_Registration_Link_to_Client__c, Create_Survey_Link__c, Invoice_Sent_to_Accounting__c, Cards_Charged__c, Event_Setup_in_Accounting__c, Resource_Center_Setup__c,
                    Setup_in_Accounting__c, Finalize_TA_Staffing__c, Place_Book_Order__c, Confirm_Books_Received_by_Client__c, Client_POC_Contacted__c,Self_study_Orders_Placed__c,
                    Complete_Training_Recap__c, Submit_Expenses_By__c, Send_Invoice_to_Accounting__c, Post_Sign_In_Sheet__c, Charge_Cards__c, Registration_Link_Sent__c,
                    LOA_SOW_Status__c, Resource_Assignment_Status__c, Client_POC_Contacted_Status__c, Book_Order_Status__c, Registration_Link_Status__c,Final_TAT_Received_Actual__c,
                    Survey_Link_Status__c, Sign_In_Sheet_Status__c, Books_Received_by_Client_Status__c, TA_Staffing_Complete_Status__c, Training_Recap_Status__c, Expenses_Submitted_Status__c,
                    Draft_Invoice_Status__c, Case_Study_Pre_reading_Status__c, Charge_Cards_Status__c, Survey_Set_Up__c,Self_study_Order_s_Delivered__c, Welcome_Email_Sent__c,
                    Timeline_Planning_Call__c, Place_Self_study_Order_s__c, SS_Order_Delivery_E_book_Live__c, Book_Delivered_to_Student_E_book_Live__c,Setup_Resource_Center__c, Final_TAT_Received_Target__c,
                    Send_Welcome_Email__c, Case_Study_Pre_reading_Open__c, Timeline_Planning_Call_Status__c,Resource_Center_Setup_Status__c,Welcome_Email_Status__c,Self_study_Order_s_Status__c 
                    from Event_Schedule__c]){

        EventMgrController Obj = new EventMgrController();
        Obj.getStatus(ES);
        Obj.getNextDueDate(ES);
        Obj.eventScheduleId = ES.Id;
        Obj.getEventDet();
        Obj.Save();
        Obj.Cancel();
        Boolean Val = Obj.IsAcademicClientEvent;
        Val = Obj.IsAcademicSalesforceEvent;
        Val = Obj.IsCorporateEvent;
        Val = Obj.IsDefaultEvent;
        }
    }
}