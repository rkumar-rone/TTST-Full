/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 11-22-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_Constants {
    
    public static final String CDI_CATEGORY_ROOT = 'CDI_Category_Root';
    public static final String STOREFRONT_NAME = 'CDI';
    public static final String CDI_CATEGORY_DOMESTIC = 'Domestic';
    public static final String CDI_CATEGORY_INTERNATIONAL = 'International';
    public static final String CDI_PRODUCT_GROUP_ID = 'ST';
    public static final String CDI_PRODUCT_PRIMARY = 'Primary';
    public static final String CDI_PRODUCT_ADDONS = 'AddOn';
    public static final String CDI_PRODUCT_BOOKS = 'Book';

    public static final String CDI_SHIPPING_PRODUCT_EXIST= 'shipping_item_exist';
    public static final String CDI_CART_ITEMS_BY_PRODUCT = 'cart_item_by_product';

    public static final String CDI_SHIPPING_SERVICE = 'Service';
    public static final String CDI_SHIPPING_CONFIGURATION = 'Configuration';
    public static final String CDI_SHIPPER_UPS = 'UPS';
    public static final String CDI_SHIPPER_USPS = 'USPS';
    public static final String CDI_SHIPPER_ACCOUNT_NUMBER = 'shipper_account_number';
    public static final String CDI_SHIPPER_LICENSE_NUMBER = 'shipper_license_number';
    public static final String CDI_SHIPPER_MAXIMUM_WEIGHT = 'shipper_maximum_weight';
    public static final String UPS_LICENSE_NUMBER = 'ups_license_number';
    public static final String UPS_USERNAME = 'ups_username';
    public static final String UPS_PASSWORD = 'ups_password';
    public static final String CART_ENCRYPTED_ID = 'cart_encryptedId';
    public static final String UPS_REQUEST_ACTION = 'ups_request_action';
    public static final String UPS_REQUEST_OPTION = 'ups_request_option';
    public static final String SERVICE_TYPE = 'ups_service_type';
    public static final String PACKAGING_WEIGHT = 'packaging_weight';
    public static final String PACKAGING_WEIGHT_CODE = 'packaging_weight_code';
    public static final String PACKAGING_TYPE = 'packaging_type';
    public static final String SHIPPER_NAME = 'shipper_name';
    public static final String SHIPPER_ATTENTION_NAME = 'shipper_attention_name';
    public static final String SHIPPER_PHONE_NUMER = 'shipper_phone_number';
    public static final String SHIPPER_FAX_NUMBER = 'shipper_fax_number';
    public static final String SHIPPER_ACCOUNT_NUMBER = 'shipper_account_number';
    public static final String SHIPPER_ADDRESS1 = 'shipper_address1';
    public static final String SHIPPER_CITY = 'shipper_city';
    public static final String SHIPPER_STATE = 'shipper_state';
    public static final String SHIPPER_POSTAL_CODE = 'shipper_postal_code';
    public static final String SHIPPER_COUNTRY_CODE = 'shipper_country_code';
    public static final String SHIP_FROM_NAME = 'ship_from_name';
    public static final String SHIP_FROM_ATTENTION_NAME = 'ship_from_attention_name';
    public static final String SHIP_FROM_PHONE_NUMER = 'ship_from_phone_number';
    public static final String SHIP_FROM_FAX_NUMBER = 'ship_from_fax_number';
    public static final String SHIP_FROM_ADDRESS1 = 'ship_from_address1';
    public static final String SHIP_FROM_CITY = 'ship_from_city';
    public static final String SHIP_FROM_STATE = 'ship_from_state';
    public static final String SHIP_FROM_POSTAL_CODE = 'ship_from_postal_code';
    public static final String SHIP_FROM_COUNTRY_CODE = 'ship_from_country_code';
    public static final String SHIP_TO_NAME = 'ship_to_name';
    public static final String SHIP_TO_ATTENTION_NAME = 'ship_to_attention_name';
    public static final String SHIP_TO_PHONE_NUMER = 'ship_to_phone_number';
    public static final String SHIP_TO_FAX_NUMBER = 'ship_to_fax_number';
    public static final String SHIP_TO_ADDRESS1 = 'ship_to_address1';
    public static final String SHIP_TO_CITY = 'ship_to_city';
    public static final String SHIP_TO_STATE = 'ship_to_state';
    public static final String SHIP_TO_POSTAL_CODE = 'ship_to_postal_code';
    public static final String SHIP_TO_COUNTRY_CODE = 'ship_to_country_code';
    public static final String SHIP_TO_COUNTRY = 'ship_to_country';
    public static final String SHIPPING_REQUEST_BODY = 'shipping_request_body';
    public static final String SHIPPING_RESPONSE_BODY = 'shipping_response_body';
    public static final String SHIPPING_RESPONSE_REASON_CODE = 'shipping_response_reason_code';
    public static final String UPS_ENDPOINT = 'ups_endpoint';
    public static final String USPS_ENDPOINT = 'http://production.shippingapis.com/ShippingAPI.dll';
    public static final String USPS_API_RATE_V4 = 'RateV4';
    public static final String USPS_API_INTL_RATE_V2 = 'IntlRateV2';
    public static final String USPS_API = 'usps_api';
    public static final String UPS_SHIPPING_RATE_API ='/rest/Rate';//'/ups.app/xml/Rate';
    public static final String CDI_ALL_SHIPPER = 'cdi_all_shipper';
    public static final String CDI_SHIPMENT_DOMESTIC = 'Domestic';
    public static final String CDI_SHIPMENT_INTERNATIONAL= 'International';
    public static final String CDI_SHIPMENT = 'shipment';

    public static final String IS_SUCCESS = 'isSuccess' ;
    public static final String MESSAGE = 'msg' ;
    public static final String IS_USER_EXIST = 'isUserExist';

    public static final String STOREFRONT = 'Gearflex New';
    public static final String ACTIVE_CART = 'active';
    public static final String CURRENT_CART = 'current';

    //Registration Specific Constants
    public static final String FIRSTNAME = 'firstName' ;
    public static final String LASTNAME = 'lastName' ;
    public static final String EMAIL = 'email' ;
    public static final String USERNAME = 'userName' ;
    public static final String PHONE = 'phone' ;
    public static final String COMPANY = 'company' ;
    public static final String COMPANYWEB = 'companyWebsite' ;
    public static final String USERNAME_PREFIX = 'UsernamePrefix';
    public static final String LOGIN_URL = 'loginUrl' ;
    public static final String PASSWORD = 'password' ;
    public static final String CONFIRM_PASSWORD = 'confirmPassword' ;
    public static final String COUNTRY_CODE = 'countryCode' ;
    public static final String STATE_CODE = 'stateCode' ;
    public static final String COMMUNITY_PATH = 'communityPath' ;
    public static final String START_URL = 'startUrl' ;
    public static final String SSO_URL = 'ssoUrl' ;
    public static final String SSO_MODULE = 'SSO' ;
    public static final String STRIVACITY_AUTH_PROVIDER = 'StrivacityAuthProvider' ;
    

    public static final String DEFAULT_SALES_REP_ID = 'DefaultSalesRepId';

    public static final String USER_ID = 'userId' ;
    public static final String ACCOUNT_ID = 'accountId' ;
    public static final String ADDRESS_TYPE_BILLING = 'Billing' ;
    public static final String ADDRESS_TYPE_SHIPPING = 'Shipping' ;
    public static final String CONTACT_ID = 'contactId' ;

    public static final String REGISTRATION_COST = 'Registration Cost';
    public static final String EARLY_BIRD_PRICE = 'Early Bird Price';
    public static final String BUNDLE_NAME = 'Bundle';
    public static final String SELF_STUDY_NAME = 'Self-Study';

    //Group Order Constants
    public static final String FIELD_IS_GROUPORDER = 'IsGroupOrder__c';

    public static final String PARAM_CARTSUMMARY = 'cartSummary';
    public static final String PARAM_CARTITEMS = 'cartItems';
    public static final String PARAM_RECIPIENTS = 'recipients';
    public static final String PARAM_WAITLISTEDPRODUCTS = 'waitlistedProducts';
    public static final String PARAM_WEBSTOREID = 'webStoreId';
    public static final String PARAM_EFFECTIVEACCOUNTID = 'effectiveAccountId';
    public static final String PARAM_CARTPROMOTION = 'cartPromotions';
    public static final String PARAM_CART = 'cart';
    public static final String PARAM_WAITLIST = 'waitlist';
    public static final String PARAM_SUMMARYGTM = 'summaryGTM';
    public static final String PARAM_MISSIING_MSG = 'MapParams missing attributes.';
    public static final String PARAM_QUANTITY = 'quantity';
    public static final String PARAM_ITEM_ID = 'itemId';
    public static final String PARAM_RES = 'res';
    public static final String PARAM_CARTTOUPDATE = 'cartToUpdate';
    public static final String PARAM_ISWAITLISTED = 'isWaitListed';
    public static final String PARAM_ISGROUPORDER = 'isGroupOrder';
    public static final String PARAM_CARTITEMSTOUPDATE = 'cartItemsToUpdate';
    public static final String PARAM_PRODUCT = 'Product';
    public static final String PARAM_PAYMENTAUTHID = 'authorizationId';
    public static final String PARAM_UPDATEDCART = 'updatedCart';
    public static final String PARAM_GROUPRECIPIENTS = 'groupRecipients';
    public static final String PARAM_ISGROUPRECIPIENTSMATCH = 'isGroupRecipientsMatch';
    public static final String PARAM_ISORDERFORSOMEONEELSE = 'isOrderForSomeoneElse';

    //Cybersource
    public static final String PARAM_PAYMENTTYPE = 'paymentType';
    public static final String PARAM_PAYMENTTYPE_AUTH = 'auth';
    public static final String PARAM_AUTHRESPONSE = 'authResponse';
    public static final String PARAM_TOKEN = 'token';
    public static final String PARAM_ERRORMAP = 'errorMap';
    public static final String PARAM_AMOUNT = 'amount';
    public static final String PARAM_CURRENCYISOCODE = 'currencyISOCode';
    public static final String PARAM_STREET = 'street';
    public static final String PARAM_CITY = 'city';
    public static final String PARAM_REGION = 'region';
    public static final String PARAM_POSTALCODE = 'postalCode';
    public static final String PARAM_COUNTRY = 'country';
    public static final String PARAM_CONTENT = 'content';
    public static final String PARAM_PAYMENTINFO = 'paymentInformation';
    public static final String PARAM_CARD = 'card';
    public static final String PARAM_NUMBER = 'number';
    public static final String PARAM_MASKEDVALUE = 'maskedValue';
    public static final String PARAM_EXPIRATIONYEAR = 'expirationYear';
    public static final String PARAM_EXPIRATIONMONTH = 'expirationMonth';
    public static final String PARAM_MASTERCARD_CAPS = 'MasterCard';
    public static final String PARAM_MASTERCARD_NOCAPS = 'mastercard';
    public static final String PARAM_MASTERCARD = 'Master Card';
    public static final String PARAM_CARDTYPE = 'cardType';
    public static final String PARAM_RESPONSE = 'response';
    public static final String PARAM_APPLICATION_JSON = 'application/json';
    public static final String PARAM_ADDRESS_STRING = 'addressString';
    public static final String PARAM_GATEWAY_TOKEN = 'gatewayToken';
    public static final String PARAM_STATUS = 'status';
    public static final String PARAM_ORDERINFORMATON = 'orderInformation';
    public static final String PARAM_AMOUNTDETAILS = 'amountDetails';
    public static final String PARAM_SUCCESS = 'success';
    public static final String PARAM_TOTALAMOUNT = 'totalAmount';
    public static final String PARAM_SF_PREFIX = 'SF';
    public static final String PARAM_ERRORINFORMATION = 'errorInformation';
    public static final String PARAM_MESSAGE = 'message';
    public static final String PARAM_ID = 'id';
    public static final String PARAM_EMPTY_STRING = '';
    public static final String PARAM_FETCHEDACCOUNT = 'fetchedAccount';
    public static final String PARAM_FETCHEDCONFIG_VALUE = 'fetchedConfigValue';
    public static final String PARAM_PAYMENT_AUTHORIZATION_ID = 'paymentAuthorizationId';
    public static final String PARAM_PAYMENT_CAPTURE_RESPONSE = 'captureResponse';
    public static final String PARAM_PAYMENT_GATEWAYTOKEN = 'gatewayToken';
    public static final String PARAM_PAYMENT_STAMPEDON_CART = 'paymentStampedOnCart';
    public static final String PARAM_PAYMENT_GATEWAY_NAME = 'CybersourcePaymentGatewayName';
    public static final String PARAM_PAYMENT_METADATA_NAME = 'CybersourcePaymentMetadata';
    public static final String PARAM_CHARGE_NOCHARGE = 'No Charge';
    public static final String PARAM_CHARGE_INVOICE = 'Invoice';
    public static final String PARAM_CHARGE_CREDITCARD = 'Credit Card';
    public static final String PARAM_CHARGE_CHARGED = 'Charged';
    public static final String PARAM_CHARGE_AUTHORIZED = 'Authorized';
    public static final String PARAM_RESPONSE_DATA = 'responseData';
    public static final String PARAM_ORIGINAL_CARD_TYPE = 'originalCardType';
    public static final String PARAM_ORGINALCARDTYPE_FIELD_NAME = 'Original_Card_Type__c';
    public static final String PARAM_PAYMENT_METHODID = 'paymentMethodId';
    public static final String PARAM_PAYMENT_GROUPID = 'paymentGroupId';
    public static final String PARAM_CONVERTED_AMOUNT = 'convertedTotalAmount';
    public static final String PARAM_SALE_RESPONSE = 'saleResponse';
    public static final String PARAM_AUTHORIZED_AMOUNT = 'authorizedAmount';

    public static final String CHK_INV_STATUS_SUCCESS = 'Success';


    //Checkout Billing Constants - GArora - 20 Sep 2024
    public static final String BILLING_ACCOUNT_ID = 'AccountId';
    public static final String CART_ID = 'CartId';
    public static final String ADDRESS_TYPE = 'AddressType';
    public static final String ADDRESS = 'Address';
    public static final String ADDRESSES = 'Addresses';
    public static final String SHIPPING_ADDRESSES = 'ShippingAddresses';
    public static final String BILLING_NAME = 'Billing Address';
    public static final String BILLING_DOMESTIC = 'Domestic';
    public static final String BILLING_INTERNATIONAL = 'International';
    public static final String DOMESTIC_COUNTRY_CODE = 'US';

    public static final String PARAM_EXCEPTION = 'exception';

    //Course Review and API Constants
    public static final String COURSECHECK_MODULE = 'CourseCheckAPI';
    public static final String PDP_LIMIT_MODULE = 'PDPReviewLimit';
    public static final String COURSE_REVIEW_BATCH_SIZE = 'CourseReviewBatchSize';
    public static final String COURSE_PARAM = 'course';
    public static final String HTTP_BASIC_AUTHORIZATION = 'BASIC';
    public static final String HTTP_GET_METHOD = 'GET';
    public static final String HTTP_AUTHORIZATION_HEADER = 'Authorization';
    public static final String HTTP_METHOD = 'Method';
    public static final String HTTP_ENDPOINT = 'Endpoint';
    public static final String HTTP_RESPONSE = 'Response';
    public static final String COURSE_ID = 'CourseId';
    public static final String REVIEWS = 'Reviews';
    public static final String AVERAGE_RATING = 'AverageRating';
    public static final String TOTAL_RATINGS = 'TotalRatings';

    //Object API's
    public static final String PRODUCT_API_NAME = 'Product2';

    public static final String Active = 'Active';
    public static final String WEBSTOREID = 'webstoreId';
    public static final String CARTID = 'cartId';

    //PDP
    public static final String VIDEO = 'Video';
    public static final String DOCUMENT = 'Document';
    public static final String IMAGE = 'Image';
    public static final String SELECTED_SESSIONS = 'selectedSessions';
    public static final String SELECTED_SESSION_NUMBER = 'selectedSessionNumber';
    public static final String IS_CART_AMT_ZERO = 'isCartAmtZero';

    
    //PLP - garora@rafter.one - 26 Sep 2024
    public static final String CATEGORY_ID = 'CategoryId';
    public static final String CATEGORY_NAME = 'CategoryName';
    public static final String STOREFRONT_MODULE = 'StorefrontName';
    public static final String SEARCH_RESULTS = 'searchResults';
    public static final String PLP_CONFIG = 'plpConfig';
    public static final String CUSTOM_PLP = 'customPLP';
    public static final String PAGE = 'page';
    public static final String PAGESIZE = 'pageSize';
    public static final String TERM = 'term';
    public static final String SORT_RULE_ID = 'sortRuleId';
    public static final String REFINEMENTS = 'refinements';
    public static final String NAME_OR_ID = 'nameOrId';
    public static final String ATTRIBUTE_TYPE = 'attributeType';
    public static final String VALUES = 'values';

    
    //Avalara Tax Integration Constants - 27 Sep 2024
    public static final String AVALARA_METADATA_AVATAX = 'AvaTax';
    public static final String DELIVERY_FORMAT_IN_PERSON = 'In-person';
    public static final String PRODUCT_GROUP_PUBLIC_COURSE = 'Public Course';
    public static final String PRODUCT_GROUP_PRIVATE_COURSE = 'Private Course';
    public static final String TAX_TYPE_SALESORDER = 'SalesOrder';
    public static final String TAX_TYPE_SALESINVOICE = 'SalesInvoice';
    public static final String CART_TAX_NAME = 'Avalara Tax - ';
    public static final String POST_METHOD = 'POST';
    public static final String CARTITEM_TYPE = 'Product';

    public static final String PRODUCT_ID = 'productId';
    public static final String PRODUCT_ID_LIST = 'productIdList';
    public static final String RELATED_PRODUCT_MAP = 'relatedProductMap';
    public static final String NO_RELATED_PRODUCT_FOUND = 'No Related Product Found.';
    public static final String NO_PRODUCT_FOUND = 'No Products ID found.';
    public static final String Recommendations_count = 'noOfRecommendations';
    public static final String No_Of_Recommendations = 'NoOfRecommendations';
    public static final String PRODUCT = 'product';
    public static final String RECORD_ID = 'recordId';
    public static final String No_Product_Tags_Found = 'No Product Tags Found.';
    public static final String CURRENCY_CODE = 'currencyCode';
    public static final String PDP_CONFIG = 'pdpConfig';
    public static final String CUSTOM_PDP = 'customPDP';
    public static final String TAGS = 'tags';
    public static final String PDP_CONFIG_JSON_NOT_FOUND = 'PDP Config JSON not found.';
    public static final String BUNDLE_CHILD_NAMES = 'bundleChildNames';
    public static final String BUNDLE_CHILD_PRODUCT_DETAILS = 'bundleChildProductDetails';


    //Order constants
    public static final String ORDER_PM_CREDITCARD = 'Credit Card';
    public static final String ORDER_PM_INVOICE = 'Invoice';

    //Storefront Configs
    public static final String MODULE_NAME = 'moduleName';
    public static final String CONFIGS = 'configs';
    public static final String MODULE_PAYMENT = 'Payment';
    public static final String MODULE_ENCRYPTION = 'Encryption';
    public static final String CONFIG_NAME_WPSTRIVACITY_ENCKEY = 'WPStrivacityEncryptionKey';

    //Encryption Constants
    public static final String ENCRYPTION_ALGORITHM_AES256 = 'AES256';

    //FederationId
    public static final String ENCRYPTED_FEDERATION_ID = 'encrytedFederationId';

    public static final String IS_CHECKOUT_PAGE = 'isCheckoutPage';
    public static final String CART_STATUS_CHECKOUT = 'Checkout';
    public static final String ORDER_REFERENCE_NUMBER = 'orderReferenceNumber';

    public static final String IS_INDIVIDUAL_ORDER_ALLOWED = 'isIndividualOrderAllowed';
    public static final String COLLEVA_PRODUCT_QTY = 'collevaProdQty';

}