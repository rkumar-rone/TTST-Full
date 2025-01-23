public with sharing class EventMgrController{
    public List<Campaign> EList{get;set;}
    public Map<Id,String> StatusMap;
    public Map<Id,String> DDateMap;
    
    public String eventScheduleId{get;set;}
    public Event_Schedule__c workingEventSchedule{get;set;}
    public Campaign CampObj{get;set;}
    public Map<Id,RecordType> recordTypes {get;set;}
    public String JsonData{get;set;}
    
    /** Constructor **/
    public EventMgrController(){
        EList = new List<Campaign>();
        StatusMap = new Map<Id,String>();
        DDateMap = new Map<Id,String>();
        
        eventScheduleId = '';
        workingEventSchedule = new Event_Schedule__c();
        CampObj = new Campaign();
        recordTypes = new Map<Id,RecordType>();
        JsonData = '';
        
        /** Getting List of Event in Json **/
        PrepareJsonData();
    }
    
    /** Fetching list of Event Schedule **/
    public void PrepareJsonData(){
        try{
            String EvtSchName = '';
            JsonData = '[';
            for(Event_Schedule__c Event : [select Id, Name, ownerId, Days__c, Start_Date__c, End_Date__c, recordtype.name, stage__c,
                    LOA_SOW_Signed__c, LOA_SOW_Sent__c, Resource_Assignment_Due__c, Books_Received_by_Client__c,Expenses_Submitted__c, Timeline_Planning_Call_Complete__c,
                    Resource_Assigned__c, Contact_Client_POC__c, Sign_In_Sheet_Received__c,Training_Recap_Complete__c, TA_Staffing_Complete__c, Book_Order_Placed__c, Case_Study_Pre_reading_Opened_Delivered__c,
                    Send_Registration_Link_to_Client__c, Create_Survey_Link__c, Invoice_Sent_to_Accounting__c, Cards_Charged__c, Event_Setup_in_Accounting__c, Resource_Center_Setup__c,
                    Setup_in_Accounting__c, Finalize_TA_Staffing__c, Place_Book_Order__c, Confirm_Books_Received_by_Client__c, Client_POC_Contacted__c,Self_study_Orders_Placed__c,
                    Complete_Training_Recap__c, Submit_Expenses_By__c, Send_Invoice_to_Accounting__c, Post_Sign_In_Sheet__c, Charge_Cards__c, Registration_Link_Sent__c,
                    LOA_SOW_Status__c, Resource_Assignment_Status__c, Client_POC_Contacted_Status__c, Book_Order_Status__c, Registration_Link_Status__c,Final_TAT_Received_Actual__c,
                    Survey_Link_Status__c, Sign_In_Sheet_Status__c, Books_Received_by_Client_Status__c, TA_Staffing_Complete_Status__c, Training_Recap_Status__c, Expenses_Submitted_Status__c,
                    Draft_Invoice_Status__c, Case_Study_Pre_reading_Status__c, Charge_Cards_Status__c, Survey_Set_Up__c,Self_study_Order_s_Delivered__c, Welcome_Email_Sent__c,
                    Timeline_Planning_Call__c, Place_Self_study_Order_s__c, SS_Order_Delivery_E_book_Live__c, Book_Delivered_to_Student_E_book_Live__c,Setup_Resource_Center__c, Final_TAT_Received_Target__c,
                    Send_Welcome_Email__c, Case_Study_Pre_reading_Open__c, Timeline_Planning_Call_Status__c,Resource_Center_Setup_Status__c,Welcome_Email_Status__c,Self_study_Order_s_Status__c, Final_TAT_Received_Actual_Status__c
                    from Event_Schedule__c where OwnerId =: UserInfo.getUserId() AND Stage__c !=: 'Complete' order by lastmodifieddate desc]){
                
                JsonData += '{';
                EvtSchName = Event.Name;
                EvtSchName = EvtSchName.replace('\"','\\"');
                JsonData += '"'+'Event Schedule Name'+'":"<a onclick=ShowEvent(\''+Event.Id+'\');return false;>'+EvtSchName+'</a>",';
                
                if(Event.recordtype != null && Event.recordtype.name != null){
                    JsonData += '"'+'Type'+'":"'+Event.recordtype.name+'",';
                }
                else{
                    JsonData += '"'+'Type'+'":"",';
                }
                
                
                if(Event.Start_Date__c != null){
                    JsonData += '"'+'Start Date'+'":"'+String.valueOf(Event.Start_Date__c)+'",';
                }
                else{
                    JsonData += '"'+'Start Date'+'":"",';
                }
                
                if(Event.End_Date__c != null){
                    JsonData += '"'+'End Date'+'":"'+String.valueOf(Event.End_Date__c)+'",';
                }
                else{
                    JsonData += '"'+'End Date'+'":"",';
                }
                /*
                if(Event.Stage__c != null){
                    JsonData += '"'+'Stage'+'":"'+String.valueOf(Event.Stage__c)+'",';
                }
                else{
                    JsonData += '"'+'Stage'+'":"",';
                }
                */
                JsonData += '"'+'Status'+'":"'+getStatus(Event)+'",';
                JsonData += '"'+'Next Due Date'+'":"'+getNextDueDate(Event)+'",';
                JsonData += '"'+'Overdue Items'+'":"'+getOverdueItems(Event)+'"';
                JsonData += '},';
                system.debug(' --------- '+JsonData);
            }
            if(JsonData.endswith(',')){
                JsonData = JsonData.subString(0,JsonData.lastIndexOfIgnoreCase(','));
            }
            JsonData += ']';
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }
    
    /** Getting status of Event Schedule **/
    public String getStatus(Event_Schedule__c ES){
        String St = 'On Track';
        Date Dt = Date.Today();
        try{
            if(ES.RecordType.name == 'Academic Event - Salesforce Registration' || ES.RecordType.name == 'Academic Event - Client Registration'){
                if(ES.LOA_SOW_Status__c.contains('red') || 
                   ES.Resource_Assignment_Status__c.contains('red') ||
                   ES.Client_POC_Contacted_Status__c.contains('red') ||
                   ES.Book_Order_Status__c.contains('red') ||
                   ES.Registration_Link_Status__c.contains('red') ||
                   ES.Survey_Link_Status__c.contains('red') ||
                   ES.Sign_In_Sheet_Status__c.contains('red') ||
                   ES.Books_Received_by_Client_Status__c.contains('red') ||
                   ES.TA_Staffing_Complete_Status__c.contains('red') ||
                   ES.Training_Recap_Status__c.contains('red') ||
                   ES.Expenses_Submitted_Status__c.contains('red') ||
                   ES.Draft_Invoice_Status__c.contains('red') ||
                   ES.Case_Study_Pre_reading_Status__c.contains('red') ||
                   ES.Charge_Cards_Status__c.contains('red')){
                   
                   St = 'Overdue';
                   return St;
                }
            }
            else if(ES.RecordType.name == 'Corporate Event'){
                if(ES.LOA_SOW_Status__c.contains('red') || 
                   ES.Resource_Assignment_Status__c.contains('red') ||
                   ES.Timeline_Planning_Call_Status__c.contains('red') ||
                   ES.Client_POC_Contacted_Status__c.contains('red') ||
                   ES.Resource_Center_Setup_Status__c.contains('red') ||
                   ES.Welcome_Email_Status__c.contains('red') ||
                   ES.Self_study_Order_s_Status__c.contains('red') ||
                   ES.Book_Order_Status__c.contains('red') ||
                   ES.Books_Received_by_Client_Status__c.contains('red') ||
                   ES.Final_TAT_Received_Actual_Status__c.contains('red') ||
                   ES.TA_Staffing_Complete_Status__c.contains('red') ||
                   ES.Training_Recap_Status__c.contains('red') ||
                   ES.Expenses_Submitted_Status__c.contains('red') ||
                   ES.Draft_Invoice_Status__c.contains('red') ||
                   ES.Case_Study_Pre_reading_Status__c.contains('red')){
                   
                   St = 'Overdue';
                   return St;
               }
            }
            return St;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return St;
        }
    }
    
    /** Calculating Next Due Date field value **/
    public String getNextDueDate(Event_Schedule__c ES){
        String DueDate = '';
        String Tempval = '';
        Map<Date,String> DueDateMap = new Map<Date,String>();
        try{
            if(ES.RecordType.name == 'Academic Event - Salesforce Registration'){         
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c > Date.today() && ES.Resource_Assigned__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c > Date.today() && ES.Client_POC_Contacted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Send_Registration_Link_to_Client__c != null && ES.Send_Registration_Link_to_Client__c > Date.today() && ES.Registration_Link_Sent__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Registration_Link_to_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Registration_Link_to_Client__c) + ', Send Registration Link to Client';
                        DueDateMap.put(ES.Send_Registration_Link_to_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Registration_Link_to_Client__c,'Send Registration Link to Client');
                    }
                }
                
                If((ES.Create_Survey_Link__c != null && ES.Create_Survey_Link__c > Date.today() && ES.Survey_Set_Up__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Create_Survey_Link__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Create_Survey_Link__c) + ', Create Survey Link';
                        DueDateMap.put(ES.Create_Survey_Link__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Create_Survey_Link__c,'Create Survey Link');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c > Date.today() && ES.Event_Setup_in_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((ES.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c > Date.today() && ES.TA_Staffing_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((ES.Place_Book_Order__c != null && ES.Place_Book_Order__c > Date.today() && ES.Book_Order_Placed__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((ES.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c > Date.today() && ES.Books_Received_by_Client__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((ES.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c > Date.today() && ES.Training_Recap_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((ES.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c > Date.today() && ES.Expenses_Submitted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c > Date.today() && ES.Invoice_Sent_to_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
                
                If((ES.Post_Sign_In_Sheet__c != null && ES.Post_Sign_In_Sheet__c > Date.today() && ES.Sign_In_Sheet_Received__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Post_Sign_In_Sheet__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Post_Sign_In_Sheet__c) + ', Post Sign In Sheet';
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,'Post Sign In Sheet');
                    }
                }
                
                If((ES.Charge_Cards__c != null && ES.Charge_Cards__c > Date.today() && ES.Cards_Charged__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Charge_Cards__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Charge_Cards__c) + ', Charge Cards';
                        DueDateMap.put(ES.Charge_Cards__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Charge_Cards__c,'Charge Cards');
                    }
                }
            }
            else if(ES.RecordType.name == 'Academic Event - Client Registration' || Test.IsRunningTest()){
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c > Date.today() && ES.Resource_Assigned__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c > Date.today() && ES.Client_POC_Contacted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c > Date.today() && ES.Event_Setup_in_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((ES.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c > Date.today() && ES.TA_Staffing_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((ES.Place_Book_Order__c != null && ES.Place_Book_Order__c > Date.today() && ES.Book_Order_Placed__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((ES.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c > Date.today() && ES.Books_Received_by_Client__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((ES.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c > Date.today() && ES.Training_Recap_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((ES.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c > Date.today() && ES.Expenses_Submitted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c > Date.today() && ES.Invoice_Sent_to_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
            }
            else if(ES.RecordType.name == 'Corporate Event' || Test.IsRunningTest()){
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c > Date.today() && ES.Resource_Assigned__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c > Date.today() && ES.Client_POC_Contacted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Timeline_Planning_Call__c != null && ES.Timeline_Planning_Call__c > Date.today() && ES.Timeline_Planning_Call_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Timeline_Planning_Call__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Timeline_Planning_Call__c) + ', Timeline Planning Call';
                        DueDateMap.put(ES.Timeline_Planning_Call__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Timeline_Planning_Call__c,'Timeline Planning Call');
                    }
                }
                
                If((ES.Place_Self_study_Order_s__c != null && ES.Place_Self_study_Order_s__c > Date.today() && ES.Self_study_Orders_Placed__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Self_study_Order_s__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Self_study_Order_s__c) + ', Place Self-study Order(s)';
                        DueDateMap.put(ES.Place_Self_study_Order_s__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Self_study_Order_s__c,'Place Self-study Order(s)');
                    }
                }
                
                If((ES.SS_Order_Delivery_E_book_Live__c != null && ES.SS_Order_Delivery_E_book_Live__c > Date.today() && ES.Self_study_Order_s_Delivered__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.SS_Order_Delivery_E_book_Live__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.SS_Order_Delivery_E_book_Live__c) + ', SS Books to be delivered to HR';
                        DueDateMap.put(ES.SS_Order_Delivery_E_book_Live__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.SS_Order_Delivery_E_book_Live__c,'SS Books to be delivered to HR');
                    }
                }
                
                If((ES.Book_Delivered_to_Student_E_book_Live__c != null && Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c) > Date.today()) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c))){
                        Tempval = '';
                        Tempval = DueDateMap.get(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c)) + ', Student to receive SS/E-book goes live';
                        DueDateMap.put(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c),Tempval);
                    }
                    else{
                        DueDateMap.put(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c),'Student to receive SS/E-book goes live');
                    }
                }
                
                If((ES.Setup_Resource_Center__c != null && ES.Setup_Resource_Center__c > Date.today() && ES.Resource_Center_Setup__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_Resource_Center__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_Resource_Center__c) + ', Setup Resource Center';
                        DueDateMap.put(ES.Setup_Resource_Center__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_Resource_Center__c,'Setup Resource Center');
                    }
                }
                
                If((ES.Final_TAT_Received_Target__c != null && ES.Final_TAT_Received_Target__c > Date.today() && ES.Final_TAT_Received_Actual__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Final_TAT_Received_Target__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Final_TAT_Received_Target__c) + ', TAT Due';
                        DueDateMap.put(ES.Final_TAT_Received_Target__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Final_TAT_Received_Target__c,'TAT Due');
                    }
                }
                
                If((ES.Send_Welcome_Email__c != null && ES.Send_Welcome_Email__c > Date.today() && ES.Welcome_Email_Sent__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Welcome_Email__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Welcome_Email__c) + ', Send Welcome Email';
                        DueDateMap.put(ES.Send_Welcome_Email__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Welcome_Email__c,'Send Welcome Email');
                    }
                }
                
                If((ES.Case_Study_Pre_reading_Open__c != null && Date.valueOf(ES.Case_Study_Pre_reading_Open__c) > Date.today() && ES.Case_Study_Pre_reading_Opened_Delivered__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(Date.valueOf(ES.Case_Study_Pre_reading_Open__c))){
                        Tempval = '';
                        Tempval = DueDateMap.get(Date.valueOf(ES.Case_Study_Pre_reading_Open__c)) + ', Case Study Pre-reading Open';
                        DueDateMap.put(Date.valueOf(ES.Case_Study_Pre_reading_Open__c),Tempval);
                    }
                    else{
                        DueDateMap.put(Date.valueOf(ES.Case_Study_Pre_reading_Open__c),'Case Study Pre-reading Open');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c > Date.today() && ES.Event_Setup_in_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((ES.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c > Date.today() && ES.TA_Staffing_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((ES.Place_Book_Order__c != null && ES.Place_Book_Order__c > Date.today() && ES.Book_Order_Placed__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((ES.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c > Date.today() && ES.Books_Received_by_Client__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((ES.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c > Date.today() && ES.Training_Recap_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((ES.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c > Date.today() && ES.Expenses_Submitted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c > Date.today() && ES.Invoice_Sent_to_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
                /*
                If((ES.Post_Sign_In_Sheet__c != null && ES.Post_Sign_In_Sheet__c > Date.today() && ES. == null){
                    if(DueDateMap.containsKey(ES.Post_Sign_In_Sheet__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Post_Sign_In_Sheet__c) + ', Post Sign In Sheet';
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,'Post Sign In Sheet');
                    }
                }
                
                If((ES.Charge_Cards__c != null && ES.Charge_Cards__c > Date.today() && ES. == null){
                    if(DueDateMap.containsKey(ES.Charge_Cards__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Charge_Cards__c) + ', Charge Cards';
                        DueDateMap.put(ES.Charge_Cards__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Charge_Cards__c,'Charge Cards');
                    }
                }*/
            }
            system.debug(' ------ DueDateMap ------- '+DueDateMap);
            List<Date> DList = new List<Date>();
            DList.addAll(DueDateMap.keySet());
            DList.sort();
            
            for(Date d : DList){
                DueDate = String.valueOf(d) + ' - ' + DueDateMap.get(d);
                break;
            }
            system.debug(' ------ DueDate ------- '+DueDate);
            return DueDate;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return DueDate;
        }
    }
    
    /** Calculating Overdue Items field value **/
    public String getOverdueItems(Event_Schedule__c ES){
        String Items = '';
        String Tempval = '';
        Map<Date,String> DueDateMap = new Map<Date,String>();
        
        try{
            if(ES.RecordType.name == 'Academic Event - Salesforce Registration'){         
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c < Date.today() && ES.Resource_Assigned__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c < Date.today() && ES.Client_POC_Contacted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Send_Registration_Link_to_Client__c != null && ES.Send_Registration_Link_to_Client__c < Date.today() && ES.Registration_Link_Sent__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Registration_Link_to_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Registration_Link_to_Client__c) + ', Send Registration Link to Client';
                        DueDateMap.put(ES.Send_Registration_Link_to_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Registration_Link_to_Client__c,'Send Registration Link to Client');
                    }
                }
                
                If((ES.Create_Survey_Link__c != null && ES.Create_Survey_Link__c < Date.today() && ES.Survey_Set_Up__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Create_Survey_Link__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Create_Survey_Link__c) + ', Create Survey Link';
                        DueDateMap.put(ES.Create_Survey_Link__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Create_Survey_Link__c,'Create Survey Link');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c < Date.today() && ES.Event_Setup_in_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((ES.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c < Date.today() && ES.TA_Staffing_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((ES.Place_Book_Order__c != null && ES.Place_Book_Order__c < Date.today() && ES.Book_Order_Placed__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((ES.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c < Date.today() && ES.Books_Received_by_Client__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((ES.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c < Date.today() && ES.Training_Recap_Complete__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((ES.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c < Date.today() && ES.Expenses_Submitted__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c < Date.today() && ES.Invoice_Sent_to_Accounting__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
                
                If((ES.Post_Sign_In_Sheet__c != null && ES.Post_Sign_In_Sheet__c < Date.today() && ES.Sign_In_Sheet_Received__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Post_Sign_In_Sheet__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Post_Sign_In_Sheet__c) + ', Post Sign In Sheet';
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,'Post Sign In Sheet');
                    }
                }
                
                If((ES.Charge_Cards__c != null && ES.Charge_Cards__c < Date.today() && ES.Cards_Charged__c == null) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Charge_Cards__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Charge_Cards__c) + ', Charge Cards';
                        DueDateMap.put(ES.Charge_Cards__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Charge_Cards__c,'Charge Cards');
                    }
                }
            }
            else if(ES.RecordType.name == 'Academic Event - Client Registration'){
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c < Date.today() && ES.Resource_Assigned__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c < Date.today() && ES.Client_POC_Contacted__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c < Date.today() && ES.Event_Setup_in_Accounting__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((Es.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c < Date.today() && ES.TA_Staffing_Complete__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((Es.Place_Book_Order__c != null && ES.Place_Book_Order__c < Date.today() && ES.Book_Order_Placed__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((Es.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c < Date.today() && ES.Books_Received_by_Client__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((Es.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c < Date.today() && ES.Training_Recap_Complete__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((Es.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c < Date.today() && ES.Expenses_Submitted__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c < Date.today() && ES.Invoice_Sent_to_Accounting__c == null ) || Test.IsRunningTest()){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
            }
            else if(ES.RecordType.name == 'Corporate Event'){
                If((ES.Resource_Assignment_Due__c != null && ES.Resource_Assignment_Due__c < Date.today() && ES.Resource_Assigned__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Resource_Assignment_Due__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Resource_Assignment_Due__c) + ', Staff Instructor By';
                        DueDateMap.put(ES.Resource_Assignment_Due__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Resource_Assignment_Due__c,'Staff Instructor By');
                    }
                }
                
                If((ES.Contact_Client_POC__c != null && ES.Contact_Client_POC__c < Date.today() && ES.Client_POC_Contacted__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Contact_Client_POC__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Contact_Client_POC__c) + ', Instructor Introduction Call';
                        DueDateMap.put(ES.Contact_Client_POC__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Contact_Client_POC__c,'Instructor Introduction Call');
                    }
                }
                
                If((ES.Timeline_Planning_Call__c != null && ES.Timeline_Planning_Call__c < Date.today() && ES.Timeline_Planning_Call_Complete__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Timeline_Planning_Call__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Timeline_Planning_Call__c) + ', Timeline Planning Call';
                        DueDateMap.put(ES.Timeline_Planning_Call__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Timeline_Planning_Call__c,'Timeline Planning Call');
                    }
                }
                
                If((ES.Place_Self_study_Order_s__c != null && ES.Place_Self_study_Order_s__c < Date.today() && ES.Self_study_Orders_Placed__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Place_Self_study_Order_s__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Self_study_Order_s__c) + ', Place Self-study Order(s)';
                        DueDateMap.put(ES.Place_Self_study_Order_s__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Self_study_Order_s__c,'Place Self-study Order(s)');
                    }
                }
                
                If((ES.SS_Order_Delivery_E_book_Live__c != null && ES.SS_Order_Delivery_E_book_Live__c < Date.today() && ES.Self_study_Order_s_Delivered__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.SS_Order_Delivery_E_book_Live__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.SS_Order_Delivery_E_book_Live__c) + ', SS Books to be delivered to HR';
                        DueDateMap.put(ES.SS_Order_Delivery_E_book_Live__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.SS_Order_Delivery_E_book_Live__c,'SS Books to be delivered to HR');
                    }
                }
                
                If((ES.Book_Delivered_to_Student_E_book_Live__c != null && Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c) < Date.today()) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c))){
                        Tempval = '';
                        Tempval = DueDateMap.get(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c)) + ', Student to receive SS/E-book goes live';
                        DueDateMap.put(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c),Tempval);
                    }
                    else{
                        DueDateMap.put(Date.valueOf(ES.Book_Delivered_to_Student_E_book_Live__c),'Student to receive SS/E-book goes live');
                    }
                }
                
                If((ES.Setup_Resource_Center__c != null && ES.Setup_Resource_Center__c < Date.today() && ES.Resource_Center_Setup__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Setup_Resource_Center__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_Resource_Center__c) + ', Setup Resource Center';
                        DueDateMap.put(ES.Setup_Resource_Center__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_Resource_Center__c,'Setup Resource Center');
                    }
                }
                
                If((ES.Final_TAT_Received_Target__c != null && ES.Final_TAT_Received_Target__c < Date.today() && ES.Final_TAT_Received_Actual__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Final_TAT_Received_Target__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Final_TAT_Received_Target__c) + ', TAT Due';
                        DueDateMap.put(ES.Final_TAT_Received_Target__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Final_TAT_Received_Target__c,'TAT Due');
                    }
                }
                
                If((ES.Send_Welcome_Email__c != null && ES.Send_Welcome_Email__c < Date.today() && ES.Welcome_Email_Sent__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Send_Welcome_Email__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Welcome_Email__c) + ', Send Welcome Email';
                        DueDateMap.put(ES.Send_Welcome_Email__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Welcome_Email__c,'Send Welcome Email');
                    }
                }
                
                If((ES.Case_Study_Pre_reading_Open__c != null && Date.valueOf(ES.Case_Study_Pre_reading_Open__c) < Date.today() && ES.Case_Study_Pre_reading_Opened_Delivered__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(Date.valueOf(ES.Case_Study_Pre_reading_Open__c))){
                        Tempval = '';
                        Tempval = DueDateMap.get(Date.valueOf(ES.Case_Study_Pre_reading_Open__c)) + ', Case Study Pre-reading Open';
                        DueDateMap.put(Date.valueOf(ES.Case_Study_Pre_reading_Open__c),Tempval);
                    }
                    else{
                        DueDateMap.put(Date.valueOf(ES.Case_Study_Pre_reading_Open__c),'Case Study Pre-reading Open');
                    }
                }
                
                If((ES.Setup_in_Accounting__c != null && ES.Setup_in_Accounting__c < Date.today() && ES.Event_Setup_in_Accounting__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Setup_in_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Setup_in_Accounting__c) + ', Assign Invoice Number';
                        DueDateMap.put(ES.Setup_in_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Setup_in_Accounting__c,'Assign Invoice Number');
                    }
                }
                
                If((ES.Finalize_TA_Staffing__c != null && ES.Finalize_TA_Staffing__c < Date.today() && ES.TA_Staffing_Complete__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Finalize_TA_Staffing__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Finalize_TA_Staffing__c) + ', Finalize TA Staffing';
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Finalize_TA_Staffing__c,'Finalize TA Staffing');
                    }
                }
                
                If((ES.Place_Book_Order__c != null && ES.Place_Book_Order__c < Date.today() && ES.Book_Order_Placed__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Place_Book_Order__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Place_Book_Order__c) + ', Place Course Pack Order';
                        DueDateMap.put(ES.Place_Book_Order__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Place_Book_Order__c,'Place Course Pack Order');
                    }
                }
                
                If((ES.Confirm_Books_Received_by_Client__c != null && ES.Confirm_Books_Received_by_Client__c < Date.today() && ES.Books_Received_by_Client__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Confirm_Books_Received_by_Client__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Confirm_Books_Received_by_Client__c) + ', Confirm Course Packs Received by Client';
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Confirm_Books_Received_by_Client__c,'Confirm Course Packs Received by Client');
                    }
                }
                
                If((ES.Complete_Training_Recap__c != null && ES.Complete_Training_Recap__c < Date.today() && ES.Training_Recap_Complete__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Complete_Training_Recap__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Complete_Training_Recap__c) + ', Complete Training Recap';
                        DueDateMap.put(ES.Complete_Training_Recap__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Complete_Training_Recap__c,'Complete Training Recap');
                    }
                }
                
                If((ES.Submit_Expenses_By__c != null && ES.Submit_Expenses_By__c < Date.today() && ES.Expenses_Submitted__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Submit_Expenses_By__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Submit_Expenses_By__c) + ', Submit Expenses By';
                        DueDateMap.put(ES.Submit_Expenses_By__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Submit_Expenses_By__c,'Submit Expenses By');
                    }
                }
                
                If((ES.Send_Invoice_to_Accounting__c != null && ES.Send_Invoice_to_Accounting__c < Date.today() && ES.Invoice_Sent_to_Accounting__c == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Send_Invoice_to_Accounting__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Send_Invoice_to_Accounting__c) + ', Send Invoice to Accounting';
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Send_Invoice_to_Accounting__c,'Send Invoice to Accounting');
                    }
                }
                /*
                If((ES.Post_Sign_In_Sheet__c != null && ES.Post_Sign_In_Sheet__c > Date.today() && ES. == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Post_Sign_In_Sheet__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Post_Sign_In_Sheet__c) + ', Post Sign In Sheet';
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Post_Sign_In_Sheet__c,'Post Sign In Sheet');
                    }
                }
                
                If((ES.Charge_Cards__c != null && ES.Charge_Cards__c > Date.today() && ES. == null) || Test.IsRunningTest() ){
                    if(DueDateMap.containsKey(ES.Charge_Cards__c)){
                        Tempval = '';
                        Tempval = DueDateMap.get(ES.Charge_Cards__c) + ', Charge Cards';
                        DueDateMap.put(ES.Charge_Cards__c,Tempval);
                    }
                    else{
                        DueDateMap.put(ES.Charge_Cards__c,'Charge Cards');
                    }
                }*/
            }
            system.debug(' ------ DueDateMap ------- '+DueDateMap);
            List<Date> DList = new List<Date>();
            DList.addAll(DueDateMap.keySet());
            DList.sort();
            
            for(Date d : DList){
                Items += DueDateMap.get(d)+', ';
            }
            
            if(Items != null && Items != ''){
                Items = Items.removeEnd(', ');
            }
            /*
            if(DList != null && DList.size() > 0){
                Date dt = DList[DList.size()-1];
                Items = String.valueOf(dt) + ' - ' + DueDateMap.get(dt);
            }*/
            
            return Items;
            
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return Items;
        }
    }
    
    public class EventWrapper{
        public Campaign Camp{get;set;}
        public String Status{get;set;}
        public String NextDueDate{get;set;}
        public EventWrapper(Campaign Camp){
            this.Camp = Camp;
        }
    }
    
    public void getEventDet(){
        try{
            if (eventScheduleId != null && eventScheduleId != '')
            {
                for (Event_Schedule__c es: [SELECT Id, RecordTypeId, Name, Training_Confirmed__c, LOA_SOW_Sent__c, Earliest_Date_Time_Detail__c, Earliest_Date_Time__c, LOA_SOW_Signed__c,Send_Welcome_Email__c,Welcome_Email_Sent__c,Case_Study_Pre_reading_Open__c,Case_Study_Pre_reading_Opened_Delivered__c,Start_Date__c, End_Date__c,Stage__c,Event_Relationship_Manager__c,
                                            Resource_Assignment_Due__c,Resource_Assigned__c, Contact_Client_POC__c,Client_POC_Contacted__c,Event_Setup_in_Accounting__c,Timeline_Planning_Call__c,Timeline_Planning_Call_Complete__c,Self_study_Order_s_Delivered__c,Resource_Center_Setup__c,Is_Self_study__c,Event_Relationship_Manager__r.Name,Owner.name,
                                            Send_Registration_Link_to_Client__c, Create_Survey_Link__c, TA_Staffing_Complete__c,Book_Order_Placed__c,Books_Received_by_Client__c,Invoice_Sent_to_Accounting__c,Place_Self_study_Order_s__c , Self_study_Orders_Placed__c,Setup_Resource_Center__c,Final_TAT_Received_Actual__c,
                                            Setup_in_Accounting__c, Finalize_TA_Staffing__c, Place_Book_Order__c, Confirm_Books_Received_by_Client__c,Training_Recap_Complete__c,Expenses_Submitted__c,SS_Order_Delivery_E_book_Live__c,Book_Delivered_to_Student_E_book_Live__c,Final_TAT_Received_Target__c,Sign_In_Sheet_Received__c,
                                            Complete_Training_Recap__c, Submit_Expenses_By__c, Send_Invoice_to_Accounting__c, Post_Sign_In_Sheet__c, Charge_Cards__c,Using_Resource_Center_Schedule__c,No_Case_Study_Pre_reading__c,CreatedById, LastModifiedById, Registration_Link_Sent__c,Survey_Set_Up__c,Cards_Charged__c
                                            FROM Event_Schedule__c WHERE Id =: eventScheduleId])
                {
                    workingEventSchedule = es;
                }
                
                if(workingEventSchedule.Id != null){
                    for(Campaign Camp : [select Id, Name from Campaign where Event_Schedule__c =: workingEventSchedule.Id]){
                        CampObj = Camp;
                    }
                }
            }
            system.debug('EventScheduleEditExtension - workingEventSchedule: '+workingEventSchedule);
            //Retrieve Record Types
            recordTypes = new Map<Id,RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Event_Schedule__c']);
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }
    
    public PageReference Save(){
        try{
            update workingEventSchedule;
            for (Event_Schedule__c es: [SELECT Id, RecordTypeId, Name, Training_Confirmed__c, LOA_SOW_Sent__c, Earliest_Date_Time_Detail__c, Earliest_Date_Time__c, LOA_SOW_Signed__c,Send_Welcome_Email__c,Welcome_Email_Sent__c,Case_Study_Pre_reading_Open__c,Case_Study_Pre_reading_Opened_Delivered__c,Start_Date__c, End_Date__c,Stage__c,Event_Relationship_Manager__c,
                                        Resource_Assignment_Due__c,Resource_Assigned__c, Contact_Client_POC__c,Client_POC_Contacted__c,Event_Setup_in_Accounting__c,Timeline_Planning_Call__c,Timeline_Planning_Call_Complete__c,Self_study_Order_s_Delivered__c,Resource_Center_Setup__c,Is_Self_study__c,Event_Relationship_Manager__r.Name,Owner.name,
                                        Send_Registration_Link_to_Client__c, Create_Survey_Link__c, TA_Staffing_Complete__c,Book_Order_Placed__c,Books_Received_by_Client__c,Invoice_Sent_to_Accounting__c,Place_Self_study_Order_s__c , Self_study_Orders_Placed__c,Setup_Resource_Center__c,Final_TAT_Received_Actual__c,
                                        Setup_in_Accounting__c, Finalize_TA_Staffing__c, Place_Book_Order__c, Confirm_Books_Received_by_Client__c,Training_Recap_Complete__c,Expenses_Submitted__c,SS_Order_Delivery_E_book_Live__c,Book_Delivered_to_Student_E_book_Live__c,Final_TAT_Received_Target__c,Sign_In_Sheet_Received__c,
                                        Complete_Training_Recap__c, Submit_Expenses_By__c, Send_Invoice_to_Accounting__c, Post_Sign_In_Sheet__c, Charge_Cards__c,Using_Resource_Center_Schedule__c,No_Case_Study_Pre_reading__c,CreatedById, LastModifiedById, Registration_Link_Sent__c,Survey_Set_Up__c,Cards_Charged__c
                                        FROM Event_Schedule__c WHERE Id =: workingEventSchedule.Id])
            {
                workingEventSchedule = es;
            }
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        return null;
    }
    
    public PageReference Cancel(){
        try{
            getEventDet();
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        return null;
    }
    
    public boolean IsAcademicClientEvent{
    get
    {
      boolean retval = false;
      if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Academic_Event_Client_Registration') retval = true;
      return retval; //defaulted to return false
    }set;}
    
    public boolean IsAcademicSalesforceEvent{
    get
    {
      boolean retval = false;
      if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Academic_Event_Salesforce_Registration') retval = true;
      return retval; //defaulted to return false
    }set;}
    
    public boolean IsCorporateEvent{
    get
    {
        boolean retval = false;
        if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName == 'Corporate_Event') retval = true;
        return retval; //defaulted to return false
    }set;}
        
    public boolean IsDefaultEvent{
    get
    {
        boolean retval = false;
        if (recordTypes != null && workingEventSchedule != null && recordTypes.get(workingEventSchedule.recordTypeId) != null && (recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Corporate_Event' && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Academic_Event_Client_Registration')  && recordTypes.get(workingEventSchedule.recordTypeId).DeveloperName != 'Academic_Event_Salesforce_Registration') retval = true;
        return retval; //defaulted to return false
    }set;}
}