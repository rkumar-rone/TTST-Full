/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 10-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_SetupConstants {

    public static final String CART_ENCRYPTED_ID = 'cart_encryptedId';

    public static String AUTHORIZATIONTITLE = 'Authorization';
    
    public static String ENDPOINT = 'endPoint';
    public static String METHOD = 'method';
    public static String CONTENTTYPE = 'Content-type';
    public static String CONTENT = 'contentType';
    public static String GRANTTYPE = 'grant_type';
    
    public static String BODY = 'requestBody';
    public static String PUT = 'PUT';
    public static String HTTPDELETE = 'DELETE';
    public static String POST = 'POST';
    

    public static final FedexAuthSetup FEDEX_AUTH_SETUP = new FedexAuthSetup();
    public static final ShippingServices SHIPPING_SERVICES = new ShippingServices();
    public static final UsWarehouseTypes WAREHOUSE_TYPES = new UsWarehouseTypes();
    public static final CheckInventoryStatus CHECK_INV_STATUS = new CheckInventoryStatus();

    public static final Set<String> SHIP_CONTACT_ADDRESS_TYPES = new Set<String>{
        'Shipping'
    };
    public static final Set<String> BILL_CONTACT_ADDRESS_TYPES = new Set<String>{
         'Billing'
    };

    public class FedexAuthSetup {
        
        public final String NORTH = 'Fedex NW';
        public final String EAST = 'Fedex EW';
    }

    public class ShippingServices {
        public final String FEDEX = 'FedEx';
        public final String UPS = 'UPS';
        public final String DHL = 'DHL';
    }

    public class UsWarehouseTypes {
        public final String NORTH = 'USE';
        public final String EAST = 'UTP';
    }

    public static final String TOKEN_TYPE_BEARER = 'bearer';
    public static final String GRANT_TYPE = 'grant_type';
    public static final String CLIENT_CREDENTIALS = 'client_credentials';
    public static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    public static final String UTF_CODE = 'UTF-8';
    public static final String CLIENT_ID_STRING = 'client_id';
    public static final String CLIENT_SECRET_KEY_STRING = 'client_secret';
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String POST_METHOD = 'POST';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String BEARER = 'Bearer ';
    public static final String AUTHORIZATION = 'authorization';
    
    public static final String WEIGHT_UNIT = 'LB';

    public static final String WAREHOUSE_DEFAULT_ADDRESS = 'Default_Address';

    /** NEW CODE - SHIPPING */
    
    // Shipping Provider Details
    public static final String REQUEST_MAPPER = 'request_mapper';
    public static final String REQUEST_JSON = 'request_json';
    public static final String RESPONSE_MAPPER = 'response_mapper';
    public static final String IMPL_CLASS = 'impl_class';
    public static final String MAX_PACKAGE_WEIGHT = 'max_package_weight';
    public static final String MIN_PACKAGE_WEIGHT = 'min_package_weight';
    public static final String MOCKED_RESPONSE = 'mocked_response';
    public static final String SHIPPING_METHOD_NAMES = 'shipping_method_names';
    public static final String SHIPPING_PRODUCT = 'shipping_product';
    public static final String CART_DELIVERY_GROUP = 'cart_delivery_grooup';
    public static final String PACKAGE_WEIGHT = 'package_weight';
    public static final String CART_ID = 'cart_id';

    // Service  details
    public static final String REQUEST_URL = 'request_url';
    public static final String END_POINT = 'end_point';
    public static final String HTTP_METHOD = 'http_method';
    public static final String SERVICE_TIMEOUT = 'service_timeout';
    public static final String SERVICE_MODE = 'service_mode';
    public static final String SERVICE_MODE_LIVE = 'LIVE';
    public static final String SERVICE_REQUEST_BODY = 'service_request_body';
    public static final String SERVICE_RESPONSE_BODY = 'service_response_body';
    public static final String RESPONSE_REASON_CODE = 'response_reason_code';
    public static final String SERVICE_IMPL_CLASS = 'service_impl_class';
    public static final String HTTP_POST = 'POST';
    public static final Integer HTTP_DEFAULT_TIMEOUT = 5000;
    public static final Integer HTTP_200 = 200;
    public static final Integer HTTP_400 = 400;
    public static final Integer HTTP_401 = 401;
    public static final Integer HTTP_403 = 403;
    public static final String HTTP_RESPONSE_STATUS = 'status';
    public static final String HTTP_RESPONSE_STATUS_SUCCESS = 'success';
    public static final String HTTP_RESPONSE_STATUS_ERROR = 'error';
    public static final String HTTP_HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_HEADER_CONTENT_TYPE_JSON = 'application/json';
    // Named Credentials
    public static final String NAMED_CREDENTIALS = 'named_credentials';
    public static final String CALLOUT = 'callout:';
    public static final String USERNAME = 'username';
    public static final String PASSWORD = 'password';
    public static final String CREDENNTIALS_USERNAME = '{!$Credential.Username}';
    public static final String CREDENNTIALS_PASSWORD = '{!$Credential.Password}';

    // Shipper
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

    // Ship From
    public static final String SHIP_FROM_NAME = 'ship_from_name';
    public static final String SHIP_FROM_ATTENTION_NAME = 'ship_from_attention_name';
    public static final String SHIP_FROM_PHONE_NUMER = 'ship_from_phone_number';
    public static final String SHIP_FROM_FAX_NUMBER = 'ship_from_fax_number';
    public static final String SHIP_FROM_ADDRESS1 = 'ship_from_address1';
    public static final String SHIP_FROM_CITY = 'ship_from_city';
    public static final String SHIP_FROM_STATE = 'ship_from_state';
    public static final String SHIP_FROM_POSTAL_CODE = 'ship_from_postal_code';
    public static final String SHIP_FROM_COUNTRY_CODE = 'ship_from_country_code';

    // Shit To
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

    // Cart
    public static final String EXTENSION_CART = 'extension_cart';

    public static final String STOREFRONT = 'Gearflex New';

    public static final String CONFIGURATION_TYPE_STOREFRONT = 'STOREFRONT';

    public static final String CONFIGURATION_TYPE_CHECKOUT = 'CHECKOUT';

    public static final String CONFIGURATION_TYPE_PDP = 'PDP';

    public static final String CONFIGURATION_TYPE_CART = 'CART';

    public static final String CONFIGURATION_TYPE_ORDER_DETAILS = 'ORDER DETAILS';

    public static final String CONFIGURATION_TYPE_ORDER_LIST = 'ORDER LIST';

    public static final String CONFIGURATION_TYPE_PLP = 'PLP';

    public static final String CONFIGURATION_TYPE_HOME = 'home';

    public static final String CONFIGURATION_TYPE_SIGNUP = 'SIGNUP';

    public static final String CONFIGURATION_TYPE_FOOTER = 'FOOTER';

    public static final String CONFIGURATION_TYPE_MEGA_MENU = 'MEGAMENU';

    public static final String APEX_CALL_STATUS_SUCCESS = 'success';

    public static final String APEX_CALL_STATUS_ERROR = 'error';

    public static final String DML_OPERATION_INSERT = 'insert';

    public static final String DML_OPERATION_UPDATE = 'update';

    public static final String METHOD_STATUS = 'status';

    public static final String RESPONSE_MESSAGE = 'message';

    public static final String CONFIGURATION_TYPE = 'configurationType';

    public static final String CONFIG_JSON = 'configJSON';

    public static final String FOOTER_CONFIG = 'footerConfig';

    public static final String FOOTER_CONFIG_NOT_FOUND = 'Footer Config JSON not found.';

    public static final String IS_SUCCESS = 'isSuccess';
    
    public static final String PRODUCT_ALREADY_EXIST = 'productAlreadyExist';

    public static final String CONFIG_TYPE = 'FOOTER';

    public static final String CATEGORY = 'Category';

    public static final String TYPE = 'type';

    public static final String URL = 'URL';

    public static final String SUB_CATEGORIES = 'subCategories';

    public static final String RECORDS = 'records';

    public static final String LABEL = 'Label';

    public static final String MEGA_MENU_CONFIG = 'megaMenuConfig';

    public static final String SIGNUP_CONFIG = 'signUpConfig';

    public static final String SIGNUP_CONFIG_NOT_FOUND = 'SignUp Config JSON not found.';

    public static final String RESULT_MAP = 'resultMap';

    public static final String HEADER_CONFIG_NOT_FOUND_MSG = 'Header Config JSON not found.'; 

    public static final String CART_CONFIG = 'cartConfig'; 

    public static final String CART_CONFIG_NOT_FOUND_MSG = 'Cart Config JSON not found.';
    public static final String PLP_CONFIG_NOT_FOUND_MSG = 'PLP Config JSON not found.';


    //Check inventory messages
    public static final String CHK_INV_PRODINV_PREFIX = 'The product with Id ';
    public static final String CHK_INV_PRODINV_SUFFIX = ' could not be found in the system';
    public static final String CHK_INV_THECOURSE = 'The Course ';
    public static final String CHK_INV_HASONLY = ' has only ';
    public static final String CHK_INV_SEATSAVAILABLE = ' seats available and ';
    public static final String CHK_INV_SEATSAREREQUESTED = ' seats are requested.\n';
    public static final String CHK_INV_ANEXCPOFTYPE = 'An exception of type ';
    public static final String CHK_INV_HASOCCURRED = ' has occurred: ';
    public static final String CHK_INV_STACKTRACE = ' Stacktrace: ';

    public class CheckInventoryStatus {
        public  final String STATUS_SUCCESS = 'Success';
        public  final String STATUS_WAITLIST = 'Waitlist';
        public  final String STATUS_FAILED = 'Failed';
    }

    //Cybersource attributes
    public static final String CYBERSOURCE_METHOD_GENERATEKEY = 'generateKey';
    public static final String CYBERSOURCE_GENERATEKEY_TARGET_ENDPOINT = '/microform/v2/sessions';
    public static final String CYBERSOURCE_GENKEY_REQUEST_BODY = '{"targetOrigins":["{1}"], "allowedCardNetworks": {2}, "clientVersion": "v2.0"}'; 
    public static final String CYBERSOURCE_DATEFORMAT = 'E, dd MMM yyyy HH:mm:ss z';
    public static final String CYBERSOURCE_TZ_GMT = 'GMT';
    public static final String CYBERSOURCE_PARAM_ONE = '{1}';
    public static final String CYBERSOURCE_PARAM_TWO = '{2}';
    public static final String CYBERSOURCE_DIGEST = 'Digest';
    public static final String CYBERSOURCE_SIGNATURE = 'Signature';
    public static final String CYBERSOURCE_SHA256 = 'SHA-256';
    public static final String CYBERSOURCE_SHA256EQ = 'SHA-256=';
    public static final String CYBERSOURCE_HEADER_HTTPS_PREFIX = 'https://';
    public static final String CYBERSOURCE_HEADER_HOST = 'Host';
    public static final String CYBERSOURCE_HEADER_VCMERCHANTID = 'v-c-merchant-id';
    public static final String CYBERSOURCE_HEADER_CONTENTTYPE = 'Content-Type';
    public static final String CYBERSOURCE_HEADER_DATE = 'Date';
    public static final String CYBERSOURCE_SIGNATURE_HOST = 'host: ';
    public static final String CYBERSOURCE_SIGNATURE_POST = 'post';
    public static final String CYBERSOURCE_SIGNTURE_DATECLSP = 'date: ';
    public static final String CYBERSOURCE_SIGNATURE_REQUESTTARGETCLSP = '(request-target): ';
    public static final String CYBERSOURCE_SIGNATURE_VCMERCHANTIDCLSP = 'v-c-merchant-id: ';
    public static final String CYBERSOURCE_SIGNATURE_NEWLINE = '\n';
    public static final String CYBERSOURCE_SIGNATURE_DIGESTCLSP = 'digest: ';
    public static final String CYBERSOURCE_SIGNATURE_HMACSHA256 = 'HmacSHA256';
    public static final String CYBERSOURCE_SIGNATURE_SPDATE = ' date';
    public static final String CYBERSOURCE_SIGNATURE_SPDIGEST = ' digest';
    public static final String CYBERSOURCE_SIGNATURE_SIGNATUREEQ = 'signature="';
    public static final String CYBERSOURCE_SIGNATURE_KEYID = 'keyid="';
    public static final String CYBERSOURCE_SIGNATURE_ALGORITHM_HMAC = 'algorithm="HmacSHA256", ';
    public static final String CYBERSOURCE_SIGNATURE_HEADERHOST = 'headers="host';
    public static final String CYBERSOURCE_SIGNATURE_SPREQ_TARGET = ' (request-target)';
    public static final String CYBERSOURCE_SIGNATURE_SP_VCMERCHANTID_CHAR = ' v-c-merchant-id", '; 
    public static final String CYBERSOURCE_REPLACE_CHAR_ID = '{id}';
    public static final String CYBERSOURCE_STATUS_PENDING = 'PENDING';
    public static final String CYBERSOURCE_STATUS_AUTHORIZED = 'AUTHORIZED';
    public static final String CYBERSOURCE_STATUS_REVERSED = 'REVERSED';
    public static final String CYBERSOURCE_TRANSACTION_NORMAL = 'Transaction Normal';
    public static final String CYBERSOURCE_GATEWAYRESULTCODE_00 = '00';
    public static final String CYBERSOURCE_TOKENINFO_NULL = '"tokenInformation":null,';
    public static final String CYBERSOURCE_PROCESSINGINFO_NULL = '"processingInformation":null,';
    public static final String CYBERSOURCE_MERCHANTINFO_NULL = '"merchantDefinedInformation":null,';
    public static final String CYBERSOURCE_REVERSALINFO_NULL = '"reversalInformation":null,';
    public static final String CYBERSOURCE_BILLTO_NULL = '"billTo":null,';
    public static final String CYBERSOURCE_AMOUNT_NULL = '"totalAmount":null,';
    public static final String CYBERSOURCE_CURRENCY_NULL = '"currency":null';
    public static final String CYBERSOURCE_CURRENCYZ = 'currency_z';
    public static final String CYBERSOURCE_CURRENCY = 'currency';
    public static final String CYBERSOURCE_ADAPTER_HOST = 'host';
    public static final String CYBERSOURCE_ADAPTER_VCDATE = 'v-c-date';
    public static final String CYBERSOURCE_ADAPTER_REQTARGET = '(request-target)';
    public static final String CYBERSOURCE_ADAPTER_DIGEST = 'digest';
    public static final String CYBERSOURCE_ADAPTER_COLON = ': ';
    public static final String CYBERSOURCE_ADAPTER_HEADER = 'headers="';
    public static final String CYBERSOURCE_ADAPTER_QTCMA = '", ';
    public static final String CYBERSOURCE_ADAPTER_QT = '"';
    public static final String CYBERSOURCE_ADAPTER_SIGNATURE = 'signature';
    public static final String CYBERSOURCE_REVERSAL_INFORMATION = 'reversalInformation';
    
    public static final String CYBERSOURCE_EMPTYSTRING = ' ';


    public static final Map<String, String> CYBERSOURCE_CARDTYPE_MAP = new Map<String, String>{
        'amex' => 'American Express',
        'mastercard' => 'Master Card',
        'visa' => 'Visa'
    };

    //Order extension constants
    public static final String ORDER_ITEM_TYPE_DELIVERY_CHARGE = 'Delivery Charge';
}