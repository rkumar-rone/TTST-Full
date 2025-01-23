@isTest(SeeAllData=true)
public class InvoicePDFControllerTest {

    @isTest
    static void testGeneratePDF() {
        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            // Create a test Account record
            Account testAccount = new Account(
                Name = 'Test Account'
            );
            insert testAccount;

            Contact testContact = new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@email.com'
            );
            insert testContact;

            // Create a test User record
            User testUser = new User(
                Alias = 'tuser',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User'].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'testuser2702@example.com',
                ContactId = testContact.Id
            );
            insert testUser;

        Saltbox_TestDataFactory.buildManagedOrderSummary('TestOS');
        OrderSummary testOrderSummary = [SELECT CreatedDate, CurrencyIsoCode, BillingPostalCode, BillingState, BillingStreet, BillingCity, BillingCountry, TotalAmount, OrderNumber, TotalAdjustedProductAmount, TotalProductAdjDistAmount, TotalTaxAmount FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];

            // Create a test InvoicePDFController.generatePDFParams record
            InvoicePDFController.generatePDFParams testPDFParams = new InvoicePDFController.generatePDFParams();
            testPDFParams.email = 'test@example.com';
            testPDFParams.recordId = testAccount.Id;
            testPDFParams.userId = testUser.Id;
            testPDFParams.orderSummaryId = testOrderSummary.Id;
            testPDFParams.isResend = false;

            // Call the method
            List<InvoicePDFController.generatePDFReturnVars> result = InvoicePDFController.generatePDF(new List<InvoicePDFController.generatePDFParams> { testPDFParams });

            // Verify the results
            System.assertEquals(1, result.size());
            System.assert(result[0].url.contains(testPDFParams.recordId));
            System.assert(result[0].url.contains(testPDFParams.userId));
            System.assert(result[0].url.contains(testPDFParams.orderSummaryId));
        }
    }

    @isTest
    static void testConstructorUsd() {
        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            // Create a test Account record
            Account testAccount = new Account(
                Name = 'Test Account'
            );
            insert testAccount;

            Contact testContact = new Contact(
                AccountId = testAccount.Id,
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@email.com'
            );
            insert testContact;

            // Create a test User record
            User testUser = new User(
                Alias = 'tuser',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Test',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User'].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                UserName = 'testuser2702@example.com',
                ContactId = testContact.Id
            );
            insert testUser;

            User actualUser = [SELECT City, CompanyName, Country, Email, FirstName, LastName, Name, MobilePhone, Street FROM User WHERE Id = :testUser.Id];

            // Create a test OrderSummary record
            Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
            OrderSummary testOrderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
            OrderSummary actualOrderSummary = [SELECT CreatedDate, CurrencyIsoCode, BillingPostalCode, BillingState, BillingStreet, BillingCity, BillingCountry, TotalAmount, OrderNumber, TotalAdjustedProductAmount, TotalProductAdjDistAmount, TotalTaxAmount FROM OrderSummary WHERE Id = :testOrderSummary.Id];

            List<OrderItemSummary> testOrderItemSummary = [SELECT Product2.TTS_Event__r.StartDate, Id, TotalLineAmount, Product2.TTS_Event__c, Product2.Name, Product2.Display_Price__c, Product2.Start_Date__c, Product2.End_Date__c, Product2.Training_Location_Country_formula__c, TotalAmtWithTax, Product2.VAT_Rate_Products__c FROM OrderItemSummary WHERE OrderSummaryId = :testOrderSummary.Id];
            for (OrderItemSummary ois : testOrderItemSummary) {
                ois.Product2.TTS_Event__r.StartDate = Date.today();
            }
            update testOrderItemSummary;

            // Create a test Campaign record
            Campaign testCampaign = [SELECT Id, Course_Packs_Requested__c , Total_Days__c, Session_Cost__c, Total_Class_Cost__c FROM Campaign WHERE Name = 'TestOS'];

            // Set the page parameters
            ApexPages.currentPage().getParameters().put('orderSummaryId', actualOrderSummary.Id);
            ApexPages.currentPage().getParameters().put('userId', actualUser.Id);

            // Create a test InvoicePDFController object
            ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
            InvoicePDFController controller = new InvoicePDFController(sc);

            System.assertEquals('January', controller.getMonthName(1));
            System.assertEquals('February', controller.getMonthName(2));
            System.assertEquals('March', controller.getMonthName(3));
            System.assertEquals('April', controller.getMonthName(4));
            System.assertEquals('May', controller.getMonthName(5));
            System.assertEquals('June', controller.getMonthName(6));
            System.assertEquals('July', controller.getMonthName(7));
            System.assertEquals('August', controller.getMonthName(8));
            System.assertEquals('September', controller.getMonthName(9));
            System.assertEquals('October', controller.getMonthName(10));
            System.assertEquals('November', controller.getMonthName(11));
            System.assertEquals('December', controller.getMonthName(12));
        }
    }

    @isTest
    static void testConstructorGbp() {

        UserRole userrole = [Select Id, DeveloperName From UserRole Where PortalType = 'None' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' AND IsActive = true Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
        // Create a test Account record
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@email.com'
        );
        insert testContact;

        // Create a test User record
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser3@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser2703@example.com',
            ContactId = testContact.Id
        );
        insert testUser;
        

        User actualUser = [SELECT City, CompanyName, Country, Email, FirstName, LastName, Name, MobilePhone, Street FROM User WHERE Id = :testUser.Id];

        // Create a test OrderSummary record
        Saltbox_TestDataFactory.buildManagedOrderSummaryWithCampaign('TestOS');
        OrderSummary testOrderSummaryOG = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
        testOrderSummaryOG.CurrencyIsoCode = 'GBP';
        update testOrderSummaryOG;
        OrderSummary testOrderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.Name = 'TestOS'];
        OrderSummary actualOrderSummary = [SELECT CreatedDate, CurrencyIsoCode, BillingPostalCode, BillingState, BillingStreet, BillingCity, BillingCountry, TotalAmount, OrderNumber, TotalAdjustedProductAmount, TotalProductAdjDistAmount, TotalTaxAmount FROM OrderSummary WHERE Id = :testOrderSummary.Id];

        List<OrderItemSummary> testOrderItemSummary = [SELECT Product2.TTS_Event__r.StartDate, Id, TotalLineAmount, Product2.TTS_Event__c, Product2.Name, Product2.Display_Price__c, Product2.Start_Date__c, Product2.End_Date__c, Product2.Training_Location_Country_formula__c, TotalAmtWithTax, Product2.VAT_Rate_Products__c FROM OrderItemSummary WHERE OrderSummaryId = :testOrderSummary.Id];
        for (OrderItemSummary ois : testOrderItemSummary) {
            ois.Product2.TTS_Event__r.StartDate = Date.today();
        }
        update testOrderItemSummary;

        // Create a test Campaign record
        Campaign testCampaign = [SELECT Id, Course_Packs_Requested__c , Total_Days__c, Session_Cost__c, Total_Class_Cost__c FROM Campaign WHERE Name = 'TestOS'];

        Group_Recepient__c g = new Group_Recepient__c();
        g.First_Name__c = 'Test';
        g.Last_Name__c = 'Test';
        g.Order_Summary__c = testOrderSummary.Id;
        g.TTS_Event__c = testCampaign.Id;
        g.Recepient_Email__c = 'test@email.com';
        insert g;
        
        // Set the page parameters
        ApexPages.currentPage().getParameters().put('orderSummaryId', actualOrderSummary.Id);
        ApexPages.currentPage().getParameters().put('userId', actualUser.Id);

        // Create a test InvoicePDFController object
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
        InvoicePDFController controller = new InvoicePDFController(sc);
    }

    }

    
}