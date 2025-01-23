@isTest
public class Saltbox_PaymentControllerTest {
  static void makeData() {
    Profile objProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'B2B Customer Community Plus User'
      LIMIT 1
    ];

    Account testAccount = new Account(Name = 'TestAccount');
    insert testAccount;

    Contact objContact = new Contact();
    objContact.FirstName = 'Test';
    objContact.LastName = 'User';
    objContact.AccountId = testAccount.Id;
    insert objContact;

    // Create a User
    User objUser = new User();
    objUser.Username = 'test@test.com';
    objUser.Email = 'test@test.com';
    objUser.Alias = 'tuser';
    objUser.TimeZoneSidKey = 'America/Los_Angeles';
    objUser.LocaleSidKey = 'en_US';
    objUser.EmailEncodingKey = 'UTF-8';
    objUser.ProfileId = objProfile.Id;
    objUser.LanguageLocaleKey = 'en_US';
    objUser.LastName = 'Test';
    objUser.FirstName = 'User';
    objUser.IsActive = true;
    objUser.ContactId = objContact.Id;
    insert objUser;


    WebStore testWebStore = new WebStore(
      Name = 'TestWebStore',
      DefaultLanguage = 'en_US'
    );
    insert testWebStore;
    WebCart cart = new WebCart(
      Name = 'Cart Test',
      WebStoreId = testWebStore.Id,
      AccountId = testAccount.Id
    );
    insert cart;

    Order o = new Order(
      EffectiveDate = Date.today(),
      Status = 'Draft',
      AccountId = testAccount.Id,
      BillingCountry = 'United States',
      Name = 'Test Order'
    );
    insert o;
    
  }


  @isTest
  static void testGenerateCaptureContext() {
    Test.setMock(HttpCalloutMock.class, new CaptureMock());
    String response = Saltbox_PaymentController.generateCaptureContext();
    System.assertEquals(
      'eyJraWQiOiJ6dSIsImFsZyI6IlJTMjU2In0.eyJmbHgiOnsicGF0aCI6Ii9mbGV4L3YyL3Rva2VucyIsImRhdGEiOiJJN0J3Tm1rdGtUbDRaeXovOHFzK2RoQUFFSFFwYkNwREVZQk1zY0JLV0R5T1N2WnV2QzRYa3A3enU3MWltaGZFbGUwZHlJc0phQ3FvZnlrTERxV1NTM1JKczJDaHlSdEZrV0QyNXA5cXczK21jc3N1SGlFR0h2Wm1yS1JuOExINVVFM0MiLCJvcmlnaW4iOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbSIsImp3ayI6eyJrdHkiOiJSU0EiLCJlIjoiQVFBQiIsInVzZSI6ImVuYyIsIm4iOiJqZ0FncUZ4OVg5SXNiY01sdnVva1FZZm14Y2VJampWWU9pZ0loanc3MjdYdFZraktfdGJMNV96UmNyTGVOdW5TbDFLZmNBb2JWVklLMnJuSEdxN1R1cXZ4WUZYYUZJMmpCalplRWpHYlBBVXd1eXBxeXhOS3NJVHgybzVOcVFDYUpsUjUzczVJZFRxb1pTRGdyeXdWWlNpS2QwdmtYdlVfNnAtZ09WWUhDdXVNRzVsX3UwaVh5SnlFWm1feGRucUIxRGZlWEZWcDdDd0FPSjdDTHNjQU9zVngzdE40WjVza1FSZzcyS3luNjJoRlR2MlRxX2hpcmVWdEhQV2syMWRkd1FIZUNPc04tQnltakl4S2dXSkp2VDVEejJpM1VKU1g4TGxwTUhnY0J0SE9YYkNvdmlhN25zRXhsOXRYME1ZV3dqcVA1S0JxMHNhSEgtckhQUDZTZlEiLCJraWQiOiIwNzk4ZElZakNZbFl2b3dPeWd5YWRGejJqSnh2VUR3TSJ9fSwiY3R4IjpbeyJkYXRhIjp7ImNsaWVudExpYnJhcnkiOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbS9taWNyb2Zvcm0vYnVuZGxlL3YyLjAvZmxleC1taWNyb2Zvcm0ubWluLmpzIiwiYWxsb3dlZENhcmROZXR3b3JrcyI6WyJWSVNBIiwiTUFFU1RSTyIsIk1BU1RFUkNBUkQiLCJBTUVYIiwiRElTQ09WRVIiLCJESU5FUlNDTFVCIiwiSkNCIiwiQ1VQIiwiQ0FSVEVTQkFOQ0FJUkVTIl0sInRhcmdldE9yaWdpbnMiOlsiaHR0cHM6Ly93d3cudGVzdC5jb20iXSwibWZPcmlnaW4iOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbSJ9LCJ0eXBlIjoibWYtMi4wLjAifV0sImlzcyI6IkZsZXggQVBJIiwiZXhwIjoxNjk5MzgwMDg0LCJpYXQiOjE2OTkzNzkxODQsImp0aSI6ImxXUThBUzJrQTk5UU5KMEEifQ.ayySZdgSiJf-2qQrKeBSS5KiW1PAP-bmJDBHm96A7VcH160mBpbzrOdBHyrTZCrqrDcIILz1NQdjBh9SqRV-ftCO-TmeXNjhi-9_v5Fo4Y6XzG1PMxDoh9RA5SJVIiY5Lo5R5PXAFw8GPX0zBG-yfgRjWdLXWYzZMppNTvRRRxlWdO89e8_yeuUUuCsOkbNTGvb9HAkBZg0ep8PHH0NznLn1LTjCslH1-mkc7DvTwLNUXd6qMKLMSQ3KXYfLciVap2ZkaSLrcY2_y-eUI5oSDLE9gCEGABFzVHnV_DmMr5mnLhegVJZM1pWG4hUPhEJYygs9se9FoQNiU8eOVte0BA',
      response,
      'Response should be empty'
    );
  }

  @isTest(SeeAllData=true)
  static void testTokenizeCard() {
    makeData();
    Id orderId = [SELECT Id FROM Order WHERE Name='Test Order' LIMIT 1].Id;
    Id cartId = [SELECT Id FROM WebCart WHERE Name='Cart Test' LIMIT 1].Id;
    Saltbox_PaymentController.AddressWrapper aw = new Saltbox_PaymentController.AddressWrapper();
    aw.city = 'Minneapolis';
    aw.country = 'US';
    aw.postalCode = '55401';
    aw.state = 'MN';
    aw.street = '123 Test St';
    Saltbox_PaymentController.PaymentWrapper pw = new Saltbox_PaymentController.PaymentWrapper();
    pw.cardHolderFirstName = 'Test';
    pw.cardHolderLastName = 'Test';
    pw.token = 'xxxx.ewogICAgImNvbnRlbnQiOiB7CiAgICAgICAgInBheW1lbnRJbmZvcm1hdGlvbiI6IHsKICAgICAgICAgICAgImNhcmQiOiB7CiAgICAgICAgICAgICAgICAibnVtYmVyIjogewogICAgICAgICAgICAgICAgICAgICJtYXNrZWRWYWx1ZSI6ICJYWFhYWFhYWFhYWFgxMTExIgogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQp9.zzzzz';
    pw.address = aw;
    pw.cardType = 'Visa';
    pw.expiryMonth = 12;
    pw.expiryYear = 2025;
    Test.startTest();
    User u = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'test@test.com'
      LIMIT 1
    ];
    System.runAs(u) {
      String results = Saltbox_PaymentController.tokenizeCard(
        orderId,
        cartId,
        pw
      );
      System.assertEquals('Success', results, 'Should be success');
    }
    Test.stopTest();
    // Assert the result
  }

  @isTest(SeeAllData=true)
  static void testTokenizeCardWaitlisted(){
     makeData();
    Id orderId = [SELECT Id FROM Order WHERE Name='Test Order' LIMIT 1].Id;
    WebCart cart= [SELECT Id FROM WebCart WHERE Name='Cart Test' LIMIT 1];
    cart.IsWaitlisted__c = true;
    update cart;
    Saltbox_PaymentController.AddressWrapper aw = new Saltbox_PaymentController.AddressWrapper();
    aw.city = 'Minneapolis';
    aw.country = 'US';
    aw.postalCode = '55401';
    aw.state = 'MN';
    aw.street = '123 Test St';
    Saltbox_PaymentController.PaymentWrapper pw = new Saltbox_PaymentController.PaymentWrapper();
    pw.cardHolderFirstName = 'Test';
    pw.cardHolderLastName = 'Test';
    pw.token = 'xxxx.ewogICAgImNvbnRlbnQiOiB7CiAgICAgICAgInBheW1lbnRJbmZvcm1hdGlvbiI6IHsKICAgICAgICAgICAgImNhcmQiOiB7CiAgICAgICAgICAgICAgICAibnVtYmVyIjogewogICAgICAgICAgICAgICAgICAgICJtYXNrZWRWYWx1ZSI6ICJYWFhYWFhYWFhYWFgxMTExIgogICAgICAgICAgICAgICAgfQogICAgICAgICAgICB9CiAgICAgICAgfQogICAgfQp9.zzzzz';
    pw.address = aw;
    pw.cardType = 'Visa';
    pw.expiryMonth = 12;
    pw.expiryYear = 2025;
    Test.startTest();
    User u = [
      SELECT Id, ContactId
      FROM User
      WHERE Username = 'test@test.com'
      LIMIT 1
    ];
    System.runAs(u) {
      String results = Saltbox_PaymentController.tokenizeCard(
        orderId,
        cart.Id,
        pw
      );
      System.assertEquals('Success', results, 'Should be success');
    }
    Test.stopTest();
  }

  public class CaptureMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        'eyJraWQiOiJ6dSIsImFsZyI6IlJTMjU2In0.eyJmbHgiOnsicGF0aCI6Ii9mbGV4L3YyL3Rva2VucyIsImRhdGEiOiJJN0J3Tm1rdGtUbDRaeXovOHFzK2RoQUFFSFFwYkNwREVZQk1zY0JLV0R5T1N2WnV2QzRYa3A3enU3MWltaGZFbGUwZHlJc0phQ3FvZnlrTERxV1NTM1JKczJDaHlSdEZrV0QyNXA5cXczK21jc3N1SGlFR0h2Wm1yS1JuOExINVVFM0MiLCJvcmlnaW4iOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbSIsImp3ayI6eyJrdHkiOiJSU0EiLCJlIjoiQVFBQiIsInVzZSI6ImVuYyIsIm4iOiJqZ0FncUZ4OVg5SXNiY01sdnVva1FZZm14Y2VJampWWU9pZ0loanc3MjdYdFZraktfdGJMNV96UmNyTGVOdW5TbDFLZmNBb2JWVklLMnJuSEdxN1R1cXZ4WUZYYUZJMmpCalplRWpHYlBBVXd1eXBxeXhOS3NJVHgybzVOcVFDYUpsUjUzczVJZFRxb1pTRGdyeXdWWlNpS2QwdmtYdlVfNnAtZ09WWUhDdXVNRzVsX3UwaVh5SnlFWm1feGRucUIxRGZlWEZWcDdDd0FPSjdDTHNjQU9zVngzdE40WjVza1FSZzcyS3luNjJoRlR2MlRxX2hpcmVWdEhQV2syMWRkd1FIZUNPc04tQnltakl4S2dXSkp2VDVEejJpM1VKU1g4TGxwTUhnY0J0SE9YYkNvdmlhN25zRXhsOXRYME1ZV3dqcVA1S0JxMHNhSEgtckhQUDZTZlEiLCJraWQiOiIwNzk4ZElZakNZbFl2b3dPeWd5YWRGejJqSnh2VUR3TSJ9fSwiY3R4IjpbeyJkYXRhIjp7ImNsaWVudExpYnJhcnkiOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbS9taWNyb2Zvcm0vYnVuZGxlL3YyLjAvZmxleC1taWNyb2Zvcm0ubWluLmpzIiwiYWxsb3dlZENhcmROZXR3b3JrcyI6WyJWSVNBIiwiTUFFU1RSTyIsIk1BU1RFUkNBUkQiLCJBTUVYIiwiRElTQ09WRVIiLCJESU5FUlNDTFVCIiwiSkNCIiwiQ1VQIiwiQ0FSVEVTQkFOQ0FJUkVTIl0sInRhcmdldE9yaWdpbnMiOlsiaHR0cHM6Ly93d3cudGVzdC5jb20iXSwibWZPcmlnaW4iOiJodHRwczovL3Rlc3RmbGV4LmN5YmVyc291cmNlLmNvbSJ9LCJ0eXBlIjoibWYtMi4wLjAifV0sImlzcyI6IkZsZXggQVBJIiwiZXhwIjoxNjk5MzgwMDg0LCJpYXQiOjE2OTkzNzkxODQsImp0aSI6ImxXUThBUzJrQTk5UU5KMEEifQ.ayySZdgSiJf-2qQrKeBSS5KiW1PAP-bmJDBHm96A7VcH160mBpbzrOdBHyrTZCrqrDcIILz1NQdjBh9SqRV-ftCO-TmeXNjhi-9_v5Fo4Y6XzG1PMxDoh9RA5SJVIiY5Lo5R5PXAFw8GPX0zBG-yfgRjWdLXWYzZMppNTvRRRxlWdO89e8_yeuUUuCsOkbNTGvb9HAkBZg0ep8PHH0NznLn1LTjCslH1-mkc7DvTwLNUXd6qMKLMSQ3KXYfLciVap2ZkaSLrcY2_y-eUI5oSDLE9gCEGABFzVHnV_DmMr5mnLhegVJZM1pWG4hUPhEJYygs9se9FoQNiU8eOVte0BA'
      );
      res.setStatusCode(201);
      return res;
    }
  }
}