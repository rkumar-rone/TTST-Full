@isTest
public class SIBCollevaAPITest {
    private static final String ACCOUNT_NAME = 'My Test Account';
    private static final String WEBSTORE_NAME = 'My Test WebStore';
    private static final String CART_NAME = 'My Test Cart';

    @isTest
    static void invokeCreateUsersTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        // HttpResponse res = CalloutClass.getInfoFromExternalService();
        List<SIB_CollevaAPIRequestVO> requestVoList = new List<SIB_CollevaAPIRequestVO>();
        SIB_CollevaAPIRequestVO requestVo = new SIB_CollevaAPIRequestVO();
        requestVo.actionName = 'invokeCreateUsers';
        requestVo.productId = 'Test Product';
        requestVo.email = 'test11@yopmsil.com';
        requestVo.name = 'test doe';
        requestVoList.add(requestVo);
        Test.startTest();
        List<SIB_CollevaAPIResponseVO>  result  = SIB_CollevaAPIService.processCollevaApi(requestVoList);
        SIB_CollevaAPIResponseVO resp = new SIB_CollevaAPIResponseVO();
        SIB_CollevaAPIDataVO respData = new SIB_CollevaAPIDataVO();
        respData.activeProducts = result[0].data.activeProducts;
        respData.allowedUsage = result[0].data.allowedUsage;
        resp.code = result[0].code;
        resp.data = result[0].data;
        resp.errors = result[0].errors;
        Test.stopTest();

    }

    @isTest
    static void fetchUserDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        // HttpResponse res = CalloutClass.getInfoFromExternalService();
        List<SIB_CollevaAPIRequestVO> requestVoList = new List<SIB_CollevaAPIRequestVO>();
        SIB_CollevaAPIRequestVO requestVo = new SIB_CollevaAPIRequestVO();
        requestVo.actionName = 'fetchUserDetails';
        requestVo.userId = '0';
        requestVo.productId = 'Test Product1';
        requestVo.resetBillingPeriod = false;
        requestVoList.add(requestVo);
        Test.startTest();
        List<SIB_CollevaAPIResponseVO>  result  = SIB_CollevaAPIService.processCollevaApi(requestVoList);
        SIB_CollevaAPIResponseVO resp = new SIB_CollevaAPIResponseVO();
        resp.code = result[0].code;
        resp.data = result[0].data;
        resp.errors = result[0].errors;
        Test.stopTest();

    }

    @isTest
    static void fetchUserAllowedUsageTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        // HttpResponse res = CalloutClass.getInfoFromExternalService();
        List<SIB_CollevaAPIRequestVO> requestVoList = new List<SIB_CollevaAPIRequestVO>();
        SIB_CollevaAPIRequestVO requestVo = new SIB_CollevaAPIRequestVO();
        requestVo.actionName = 'fetchUserAllowedUsage';
        requestVo.userId = '0';
        
        requestVoList.add(requestVo);
        Test.startTest();
        List<SIB_CollevaAPIResponseVO>  result  = SIB_CollevaAPIService.processCollevaApi(requestVoList);
        SIB_CollevaAPIResponseVO resp = new SIB_CollevaAPIResponseVO();
        resp.code = result[0].code;
        resp.data = result[0].data;
        resp.errors = result[0].errors;
        Test.stopTest();

    }

    @isTest
    static void fetchUserProductsTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201)); 

        // HttpResponse res = CalloutClass.getInfoFromExternalService();
        List<SIB_CollevaAPIRequestVO> requestVoList = new List<SIB_CollevaAPIRequestVO>();
        SIB_CollevaAPIRequestVO requestVo = new SIB_CollevaAPIRequestVO();
        requestVo.actionName = 'fetchUserProducts';
        requestVo.userId = '0';
        requestVo.productId = 'Test Product1';
        requestVo.productCount = 2;
        requestVo.inheritBillingPeriod = false;
        requestVoList.add(requestVo);
        Test.startTest();
        List<SIB_CollevaAPIResponseVO>  result  = SIB_CollevaAPIService.processCollevaApi(requestVoList);
        SIB_CollevaAPIResponseVO resp = new SIB_CollevaAPIResponseVO();
        resp.code = result[0].code;
        resp.data = result[0].data;
        resp.errors = result[0].errors;
        Test.stopTest();

    }

    public class MockHttpResponseGenerator implements HttpCalloutMock {
        Integer statusCode;

        public MockHttpResponseGenerator(Integer statusCode) {
            this.statusCode = statusCode;
        }

        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{  "code": 0,  "errors": [    "string"  ],  "data": {    "allowedUsage": {      "isUnlimited": true,      "hasUsageLeft": true,      "minutesLimit": 0,      "minutesLeft": 0,      "sessionsLimit": 0,      "sessionsLeft": 0,      "activeProducts": [        {          "productName": "string",          "purchaseType": "MAIN",          "usageType": "SECONDS",          "externalId": "string",          "validUntil": "string"        }      ],      "validUntil": "string"    },    "email": "string",    "role": {      "permissions": [        "CREATE_COMPOSITE_REVIEW"      ],      "level": 0,      "publicDescription": "string",      "id": 0,      "name": "string",      "updatedAt": 0,      "createdAt": 0    },    "organizationTeams": [      {        "users": [          {            "email": "string",            "role": {              "permissions": [                "CREATE_COMPOSITE_REVIEW"              ],              "level": 0,              "publicDescription": "string",              "id": 0,              "name": "string",              "updatedAt": 0,              "createdAt": 0            },            "organizationTeams": [              "string"            ],            "allowedUsage": {              "isUnlimited": true,              "hasUsageLeft": true,              "minutesLimit": 0,              "minutesLeft": 0,              "sessionsLimit": 0,              "sessionsLeft": 0,              "activeProducts": [                {                  "productName": "string",                  "purchaseType": "MAIN",                  "usageType": "SECONDS",                  "externalId": "string",                  "validUntil": "string"                }              ],              "validUntil": "string"            },            "id": 0,            "name": "string",            "updatedAt": 0,            "createdAt": 0          }        ],        "id": 0,        "name": "string",        "updatedAt": 0,        "createdAt": 0      }    ],    "id": 0,    "name": "string",    "updatedAt": 0,    "createdAt": 0  }}');
            res.setStatusCode(statusCode);
            return res;
        }
    }
}