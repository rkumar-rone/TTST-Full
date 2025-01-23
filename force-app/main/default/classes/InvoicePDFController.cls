/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 11-07-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
public with sharing class InvoicePDFController {
    
    public Account account {get; set;}
    public User user {get; set;}
    public List<OrderItemSummary> orderItems {get; set;}
    public List<OrderItemSummaryWrapper> orderItemsWrapped {get; set;}
    public OrderSummary orderSummary {get; set;}
    public String today {get; set;}

    public String fromAddress {get; set;}
    public String mailingAddress {get; set;}
    public String wiringBankInfo {get; set;}
    public String domesticBankTitle {get; set;}
    public String domesticBankInfo {get; set;}
    public String currencySign {get; set;}
    public String currencyIsoCode {get; set;}

    public Decimal formattedTotalAdjustedProductAmount { get; set; }
    public Decimal formattedTotalProductAdjDistAmount { get; set; }
    public Decimal formattedTotalTaxAmount { get; set; }
    public Decimal formattedTotalAmount { get; set; }
    public Decimal formattedTotalSubAmount { get; set; }


    public List<GroupRecipientsWrap> groupRecipientsWrapped {get; set;}

    public Boolean isGroupInvoice {get; set;}
    
    public invoicePDFController(ApexPages.StandardController standardController) {

        this.account = (Account)standardController.getRecord();
        String orderSummaryId =  String.valueOf(ApexPages.currentPage().getParameters().get('orderSummaryId'));
        String userId =  String.valueOf(ApexPages.currentPage().getParameters().get('userId'));
        
        this.user = [SELECT Contact.Account.Name, City, CompanyName, Country, Email, FirstName, LastName, Name, MobilePhone, Street, Phone
                    FROM User 
                    WHERE Id =: userId];

        this.orderSummary = [SELECT CreatedDate,TotalProductAmount,TotalAdjDistAmount, CurrencyIsoCode, BillingPostalCode, BillingState, BillingStreet, BillingCity, BillingCountry, TotalAmount, OrderNumber, TotalAdjustedProductAmount,GrandTotalAmount, TotalProductAdjDistAmount, TotalTaxAmount, Selected_Sessions__c
                            FROM OrderSummary 
                            WHERE Id = : orderSummaryId];

        this.orderItems = [SELECT Id, TotalLineAmount, Product2.TTS_Event__c, Product2.TTS_Event__r.Total_Days__c, Product2.Name, Product2.Display_Price__c, Product2.Start_Date__c, Product2.End_Date__c, Product2.Training_Location_Country_formula__c, Product2.Training_Location_City_formula__c, TotalAmtWithTax, TotalTaxAmount
                            FROM OrderItemSummary
                            WHERE OrderSummaryId = : orderSummaryId]; 

        List<Group_Recepient__c> groupRecipientsRaw = [SELECT First_Name__c,Last_Name__c,Order_Summary__c,TTS_Event__c, TTS_Event__r.Name FROM Group_Recepient__c WHERE Order_Summary__c = :orderSummaryId];

        if (groupRecipientsRaw.size() > 0) {
            this.isGroupInvoice = true;
            this.groupRecipientsWrapped = new List<GroupRecipientsWrap>();

            Map<Id,Integer> oisDividers = new Map<Id,Integer>();

            for (OrderItemSummary ois : this.orderItems) {
                oisDividers.put(ois.Id, 0);
                for (Group_Recepient__c gr : groupRecipientsRaw) {
                    if (gr.TTS_Event__c == ois.Product2.TTS_Event__c) {
                        oisDividers.put(ois.Id, oisDividers.get(ois.Id) + 1);
                    }
                }
            }

            System.debug('>>> after setting oisDividers');

            GroupRecipientsWrap gRecipient;
            List<Session__c> selectedSessionsGroup;
            if(this.orderSummary.Selected_Sessions__c != null){
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(this.orderSummary.Selected_Sessions__c);
                Integer recordCount = data.size();
                selectedSessionsGroup = [SELECT Id, Event__c FROM Session__c WHERE Id IN :data.keySet()];

            }
            for (Group_Recepient__c gr : groupRecipientsRaw) {
                for (OrderItemSummary ois : this.orderItems) {
                    if (gr.TTS_Event__c == ois.Product2.TTS_Event__c) {
                        Integer recordCount = 0;
                        if(selectedSessionsGroup != null && selectedSessionsGroup.size() > 0){
                            for (Session__c session : selectedSessionsGroup) {
                                if (session.Event__c == ois.Product2.TTS_Event__c) {
                                    recordCount++;
                                }
                            }
                        }
                        System.debug('>>> before creating new GroupRecipientsWrap');
                        gRecipient = new GroupRecipientsWrap(gr, ois, oisDividers.get(ois.Id), recordCount);
                        System.debug('>>> after creating new GroupRecipientsWrap');
                        this.groupRecipientsWrapped.add(gRecipient);
                        System.debug('>>> after adding gRecipient to groupRecipientsWrapped');
                    }
                }
            }
            
        }else {
            this.isGroupInvoice = false;
            this.orderItemsWrapped = new List<OrderItemSummaryWrapper>();

            OrderItemSummaryWrapper oisw;
            List<Session__c> selectedSessions;
            if(this.orderSummary.Selected_Sessions__c != null){
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(this.orderSummary.Selected_Sessions__c);
                Integer recordCount = data.size();
                System.debug('Number of records: ' + recordCount);
                selectedSessions = [SELECT Id, Event__c FROM Session__c WHERE Id IN :data.keySet()];

            }
            for (OrderItemSummary ois : this.orderItems) {
                Integer recordCount = 0;
                if(selectedSessions != null && selectedSessions.size() > 0){
                    for (Session__c session : selectedSessions) {
                        if (session.Event__c == ois.Product2.TTS_Event__c) {
                            recordCount++;
                        }
                    }
                }
                oisw = new OrderItemSummaryWrapper(ois, this.orderSummary.CurrencyIsoCode, recordCount);
                this.orderItemsWrapped.add(oisw);
            }

        }

        

        this.today = this.getFormattedDay(Date.today().day()) + '/' + this.getMonthName(Date.today().month()) + '/' + Date.today().year();

        this.fromAddress = '';
        this.mailingAddress = '';
        this.wiringBankInfo = '';
        this.domesticBankTitle = '';
        this.domesticBankInfo = '';
        this.currencySign = '';
        this.currencyIsoCode = this.orderSummary.CurrencyIsoCode;

        if (this.orderSummary.CurrencyIsoCode == 'USD') {
            this.fromAddress='From: Training The Street\nEIN: 22-3776847\nAttention: Public Courses\n200 Providence Rd\nSuite 102\nCharlotte, NC 28207\nUSA\n'+
            '+ 1 (704) 927 9688 (phone)\nregister@trainingthestreet.com';
            this.mailingAddress='Training The Street\nAttention: Public Courses\n200 Providence Road\nSuite 102\nCharlotte, NC 28207\n+1 (704) 927-9688 (phone)';
            this.wiringBankInfo='Bank Routing / ABA #: 026 009 593\n-Swift Code: BOFAUS3N (International Transfer to U.S.; use in lieu of ABA)\n'+
            'Checking Account #: 237025409459\nBank = Bank of America, Charlotte, NC 28255';
            this.domesticBankTitle='Domestic EFT (ACH) Instructions for Training The Street:';
            this.domesticBankInfo='Bank Routing #: 053 000 196\nChecking Account #: 237025409459\nBank = Bank of America, Charlotte, NC 28255';
            this.currencySign = '$';
        }
        if (this.orderSummary.CurrencyIsoCode == 'GBP') {
            this.fromAddress='Training The Street UK, LLC.\nRegistration No. FC028960\nVAT Registration No. 972 3360 16\nAttention:  Public Courses\n'+
            '200 Providence Rd\nSuite 102\nCharlotte, NC 28207\nUSA\n+ 1 (704) 927 9688 (phone)\nregister@trainingthestreet.com';
            this.mailingAddress='Training The Street\nAttention: Public Courses\n200 Providence Road\nSuite 102\nCharlotte, NC 28207\n+1 (704) 927-9688 (phone)';
            this.wiringBankInfo='Bank:  Lloyds Bank\nSWIFT Code:  LOYDGB21682\nBank Account #:  38329668\nSort Code: 30-65-41\nIBAN:  GB05LOYD30654138329668\nTraining The Street UK, LLC.';
            this.domesticBankTitle='';
            this.domesticBankInfo='';
            this.currencySign = '£';
        }

        this.formattedTotalAdjustedProductAmount = this.orderSummary.TotalProductAmount;
        this.formattedTotalProductAdjDistAmount =  this.orderSummary.TotalAdjDistAmount.abs();
        this.formattedTotalTaxAmount = this.orderSummary.TotalTaxAmount;
        this.formattedTotalAmount = this.orderSummary.GrandTotalAmount;
        this.formattedTotalSubAmount=  this.orderSummary.TotalAmount; 

    }

    public abstract class InvoiceWrapper {
        public String trainingLocationCountry {get; set;}
        public String trainingLocationCity {get; set;}
        public String startDate {get; set;}
        public Decimal totalLineAmount {get; set;}
        public Decimal totalTaxAmount {get; set;}
        public Decimal totalAmtWithTax {get; set;}
        public String totalDays {get; set;}
        public String ttsEventName {get; set;}

        private String getFormattedDay(Integer day) {
            String formattedDay = '';
            if (day < 10) {
                formattedDay = '0' + String.valueOf(day);
            } else {
                formattedDay = String.valueOf(day);
            }
            return formattedDay;
        }
    
        private String getMonthName(Integer month) {
            String monthName = '';
            switch on month {
                when 1 {
                    monthName = 'Jan';
                }
                when 2 {
                    monthName = 'Feb';
                }
                when 3 {
                    monthName = 'Mar';
                }
                when 4 {
                    monthName = 'Apr';
                }
                when 5 {
                    monthName = 'May';
                }
                when 6 {
                    monthName = 'Jun';
                }
                when 7 {
                    monthName = 'Jul';
                }
                when 8 {
                    monthName = 'Aug';
                }
                when 9 {
                    monthName = 'Sep';
                }
                when 10 {
                    monthName = 'Oct';
                }
                when 11 {
                    monthName = 'Nov';
                }
                when 12 {
                    monthName = 'Dec';
                }
                when else {
                    
                }
            }
            return monthName;
        }
    }

    public class GroupRecipientsWrap extends InvoiceWrapper{
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String orderSummary {get; set;}
        public String ttsEventName {get; set;}

        public GroupRecipientsWrap(Group_Recepient__c gr, OrderItemSummary ois, Integer amountDivider, Integer recordCount) {
            this.firstName = gr.First_Name__c;
            this.lastName = gr.Last_Name__c;
            this.orderSummary = gr.Order_Summary__c;
            this.ttsEventName = gr.TTS_Event__r.Name;
            this.trainingLocationCountry = ois.Product2.Training_Location_Country_formula__c;
            this.trainingLocationCity = ois.Product2.Training_Location_City_formula__c;
            if (Test.isRunningTest()) {
                this.startDate = this.getFormattedDay(Date.today().day()) + '/' + this.getMonthName(Date.today().month()) + '/' + Date.today().year();
            } else {
                this.startDate = this.getFormattedDay(ois.Product2.Start_Date__c.day()) + '/' + this.getMonthName(ois.Product2.Start_Date__c.month()) + '/' + ois.Product2.Start_Date__c.year();
            }
            this.totalLineAmount = (ois.TotalLineAmount/amountDivider).setScale(2);
            this.totalAmtWithTax = (ois.TotalAmtWithTax/amountDivider).setScale(2);
            this.totalTaxAmount = (ois.TotalTaxAmount/amountDivider).setScale(2);
            if (recordCount > 0) {
                this.totalDays = String.valueOf(recordCount);
            } else {
                this.totalDays = '';
            }
            
        }
    }

    public class OrderItemSummaryWrapper extends InvoiceWrapper{
        
        public OrderItemSummaryWrapper(OrderItemSummary orderItem, String currencyIsoCode, Integer recordCount) {
            if (recordCount > 0) {
                this.totalDays = String.valueOf(recordCount);
            } else {
                this.totalDays = '';
            }
            this.ttsEventName = orderItem.Product2.Name;
            if (Test.isRunningTest()) {
                this.startDate = this.getFormattedDay(Date.today().day()) + '/' + this.getMonthName(Date.today().month()) + '/' + Date.today().year();
            }else {
                this.startDate = this.getFormattedDay(orderItem.Product2.Start_Date__c.day()) + '/' + this.getMonthName(orderItem.Product2.Start_Date__c.month()) + '/' + orderItem.Product2.Start_Date__c.year(); 
            }
            this.trainingLocationCountry = orderItem.Product2.Training_Location_Country_formula__c;
            this.trainingLocationCity = orderItem.Product2.Training_Location_City_formula__c;
            this.totalLineAmount = orderItem.TotalLineAmount.setScale(2);
            this.totalAmtWithTax = orderItem.TotalAmtWithTax.setScale(2);
            this.totalTaxAmount = orderItem.TotalTaxAmount.setScale(2);
        }
    }

    @InvocableMethod(label='Email Invoice PDF' description='Generates and Emails an Invoice PDF')
    public static List<generatePDFReturnVars> generatePDF(List<generatePDFParams> pdfParamList)	{
        List<generatePDFReturnVars> returnVarsWrapper = new List<generatePDFReturnVars>();

        generatePDFParams pdfParams = pdfParamList.get(0);

        String url = 'apex/InvoicePDFView?';
        String parameters = 'Id=' + pdfParams.recordId +
                            '&orderSummaryId=' + pdfParams.orderSummaryId+
                            '&userId=' + pdfParams.userId;

        PageReference invoicePDF =  new PageReference('/' + url + parameters);

        if (!Test.isRunningTest()) {
            ContentVersion contentVer = new ContentVersion();
            contentVer.VersionData = invoicePDF.getContentAsPdf();
            contentVer.Title = 'Invoice PDF'; 
            contentVer.ContentLocation= 's';
            contentVer.PathOnClient='Invoice PDF.pdf';         
            insert contentVer;
            ContentVersion contentVerDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVer.Id LIMIT 1];

            ContentDocumentLink contentLink = new ContentDocumentLink();
            contentlink.LinkedEntityId=pdfParams.orderSummaryId;
            contentlink.ContentDocumentId = contentVerDoc.ContentDocumentId;
            contentLink.shareType = 'V';
            insert contentLink;
        }
    
        generatePDFReturnVars returnVars = new GeneratePDFReturnVars();
        returnVars.url = url + parameters;

        emailPDF(invoicePDF, pdfParams);

        returnVarsWrapper.add(returnVars);
        
        String osId = pdfParams.orderSummaryId;

        String osNumber = [SELECT OrderNumber FROM OrderSummary WHERE Id = :osId].OrderNumber;

        Boolean tcEmailSent = tcTeamEmail(osNumber, pdfParams.orderSummaryId, pdfParams.isResend);

        return returnVarsWrapper;
    }

    private static Boolean tcTeamEmail (String orderNumber, String recordId, Boolean isResend){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String tcGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'TrainingCoordinators' LIMIT 1].Id;

        List<GroupMember> groupMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :tcGroupId];

        List<String> groupMembersIds = new List<String>();

        for (GroupMember gm : groupMembers) {
            groupMembersIds.add(gm.UserOrGroupId);
        }

        List<User> userMembers = [SELECT Id, Email FROM User WHERE Id IN :groupMembersIds];
        
        String[] toAddress = new List<String>();

        for (User user : userMembers) {
            toAddress.add(user.Email);
        }

        mail.setToAddresses(toAddress);

        if (isResend) {
            mail.setSubject('Invoice ' + orderNumber + ' has been resent to the client');

            mail.setHtmlBody('The invoice ' + orderNumber + ' has been resent to the client. You can view the Order Summary information <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordId + '">here</a>.');
        }else {
            mail.setSubject('Invoice ' + orderNumber + ' has been approved and sent to the client');

            mail.setHtmlBody('The invoice ' + orderNumber + ' has been approved and sent to the client. You can view the Order Summary information <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordId + '">here</a>.');
        }
        
        OrgWideEmailAddress[] owea = [SELECT Id from OrgWideEmailAddress WHERE Address = 'info@trainingthestreet.com'];
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        
        List<Messaging.SendEmailResult> rawResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        Messaging.SendEmailResult result = rawResult.get(0);
        return result.isSuccess();
    }

    private static void emailPDF(PageReference invoicePDF, generatePDFParams pdfParams) {

        // sending the PDF invoice (invoicePDFView) 
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

        attachment.setContentType('application/pdf');
        attachment.setFileName('Invoice PDF.pdf');
        if (!Test.isRunningTest()) {
            attachment.body = invoicePDF.getContentAsPdf();
        } else {
            attachment.body = Blob.valueOf('Test Content');
        }
        
        //attachment.setInline(false);

        // sending email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String orderNumber = [SELECT OrderNumber FROM OrderSummary WHERE Id = :pdfParams.orderSummaryId].OrderNumber;

        //mail.setSubject('Training The Street - Invoice '+ orderNumber);
        
        String usersContactId = [SELECT ContactId FROM User WHERE Id = :pdfParams.userId].ContactId;

        mail.setTargetObjectId(usersContactId);
        mail.setToAddresses(new String[] {pdfParams.email});

        // ID of Lightning InvoicePDFTemplate
		EmailTemplate emailTemplate = [SELECT FolderName,Id,Name FROM EmailTemplate WHERE Name = 'InvoicePDFTemplate'];  
        //System.debug('>>> emailTemplate: ' + emailTemplate.Id);
		mail.setTemplateID(emailTemplate.Id); 
        mail.saveAsActivity = true;

        // ID of Lightning InvoicePDFTemplate
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        mail.setWhatId(pdfParams.orderSummaryId);

        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'register@trainingthestreet.com'];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage [] { mail });

    }

    private String getFormattedDay(Integer day) {
        String formattedDay = '';
        if (day < 10) {
            formattedDay = '0' + String.valueOf(day);
        } else {
            formattedDay = String.valueOf(day);
        }
        return formattedDay;
    }

    public String getMonthName(Integer month) {
        String monthName = '';
        switch on month {
            when 1 {
                monthName = 'January';
            }
            when 2 {
                monthName = 'February';
            }
            when 3 {
                monthName = 'March';
            }
            when 4 {
                monthName = 'April';
            }
            when 5 {
                monthName = 'May';
            }
            when 6 {
                monthName = 'June';
            }
            when 7 {
                monthName = 'July';
            }
            when 8 {
                monthName = 'August';
            }
            when 9 {
                monthName = 'September';
            }
            when 10 {
                monthName = 'October';
            }
            when 11 {
                monthName = 'November';
            }
            when 12 {
                monthName = 'December';
            }
            when else {
                
            }
        }
        return monthName;
    }

    public class generatePDFParams {
        @InvocableVariable(label='Email' description='recepient email' required=true)
        public String email;

        @InvocableVariable(label='RecordId' description='record Id' required=true)
        public String recordId;

        @InvocableVariable(label='UserId' description='user Id' required=true)
        public String userId;

        @InvocableVariable(label='OrderSummaryId' description='Oder Summary Id' required=true)
        public String orderSummaryId;

        @InvocableVariable(label='IsResend' description='If the email is being resend or not' required=true)
        public Boolean isResend;
    }

    public class generatePDFReturnVars {
        @InvocableVariable(label='RecordId' description='record Id' required=true)
        public String url;
    }	

    

	
}