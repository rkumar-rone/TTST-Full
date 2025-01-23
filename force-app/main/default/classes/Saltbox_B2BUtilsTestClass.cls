@isTest
private class Saltbox_B2BUtilsTestClass {
    @IsTest
    public static void testB2BUtilsGetUserAccountId() {
        Account a = new Account();
        a.Name = 'Test';
        insert a;

        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.AccountId = a.Id;
        insert c;

        User u = new User();
        u.Username = 'testb2buser2@test.com';
        u.LastName = 'TestLastName';
        u.Email = 'testb2buser2@test.com';
        u.Alias = 'test2';
        u.TimeZoneSidKey = 'America/New_York';
        u.EmailEncodingKey = 'ISO-8859-1';

        u.ProfileId = [select id from Profile where Name = 'Customer Community Plus User'].Id;
        
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.EmployeeNumber = '24601';
        u.ContactId = c.Id;

        insert u;

        Test.startTest();
        System.runAs(u) {
            String thisStr = Saltbox_B2BUtils.getUserAccountID();
            System.assertEquals(a.Id, thisStr);
        }
    }

    @IsTest
    public static void testB2BUtilsResolveCommunityIdToWebstoreId() {
        Saltbox_B2BUtils.communityIdToWebStoreIdCache.put('Test','Test');
        String thisStr = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId('Test');
        System.assertEquals('Test', thisStr);
    }

    @IsTest
    public static void testB2BUtilsResolveCommunityIdToWebstoreId2() {
        String thisStr = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId('Test');
        System.assertEquals(null, thisStr);
    }

    @isTest
    static void testResolveSortParam(){
        ConnectApi.CartItemSortOrder cartItemSort = Saltbox_B2BUtils.resolveSortParam('NameAsc');
        System.assertEquals(ConnectApi.CartItemSortOrder.NameAsc, cartItemSort);
    }

    @isTest
    static void testResolveSortParam2(){
        Saltbox_B2BUtils.sortOrderCache.put('NameAsc', ConnectApi.CartItemSortOrder.NameAsc);
        ConnectApi.CartItemSortOrder cartItemSort = Saltbox_B2BUtils.resolveSortParam('NameAsc');
        System.assertEquals(ConnectApi.CartItemSortOrder.NameAsc, cartItemSort);
    }
}