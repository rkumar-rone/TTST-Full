public without sharing class IdentityProviderController {
    public String getXML() {
    	Identity_Provider_Configuration__mdt ipc = [Select Id, Audience__c, Certificate__c, Certificate_Developer_Name__c, Destination__c, Entity_Id__c, Service_URL__c from Identity_Provider_Configuration__mdt where Active__c = true limit 1];
    	String xml = '<md:EntityDescriptor xmlns:ds="http://www.w3.org/2000/09/xmldsig#" validUntil="2029-02-07T04:16:13.464Z" entityID="' + ipc.Entity_Id__c + '" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata">\n<md:IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol" WantAuthnRequestsSigned="false">\n<md:KeyDescriptor use="signing">\n<ds:KeyInfo>\n<ds:X509Data>\n<ds:X509Certificate>' + ipc.Certificate__c + '</ds:X509Certificate>\n</ds:X509Data>\n</ds:KeyInfo>\n</md:KeyDescriptor>\n<md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified</md:NameIDFormat>\n<md:SingleSignOnService Location="' + ipc.Service_URL__c + '" Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"/>\n</md:IDPSSODescriptor>\n</md:EntityDescriptor>';
    	return xml;
    }
}