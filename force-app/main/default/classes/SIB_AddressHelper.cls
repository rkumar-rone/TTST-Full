/**
 * @description       : 
 * @author            : Jassimran Virdi
 * @group             : 
 * @last modified on  : 10-08-2024
 * @last modified by  : Gaurang Arora
**/
public with sharing class SIB_AddressHelper {

    public static Map<String, Object> getAllAddressesForAccount(Map<String, Object> mapParams) {
        Boolean isSuccess = false;
        String shippingType = 'Shipping';
        String billingType = 'Billing';
        String recordId = '';
        String accountId = '';
        if (mapParams.containsKey('accountId'))
        {
            accountId = (String)mapParams.get('accountId');
            List<ContactPointAddress> allAddresses = (List<ContactPointAddress>)SIB_AddressSelector.getAddressesByAccountIds(new List<Id>{accountId});
            if(allAddresses != null && allAddresses.size() > 0)
            {
                List<ContactPointAddress> billingAddresses = new List<ContactPointAddress>();
                List<ContactPointAddress> shippingAddresses = new List<ContactPointAddress>();
                for(ContactPointAddress addr : allAddresses)
                {
                    if(addr.AddressType == shippingType)
                    {
                        shippingAddresses.add(addr);
                    }else if(addr.AddressType == billingType)
                    {
                        billingAddresses.add(addr);
                    }
                }
                if(shippingAddresses.size() > 0)
                {
                    mapParams.put('shippingAddresses', shippingAddresses);
                }
                if(billingAddresses.size() > 0)
                {
                    mapParams.put('billingAddresses', billingAddresses);
                }
                isSuccess = true;
            }
        }
        mapParams.put('isSuccess', isSuccess);
        return mapParams;
    }

    /**
     * @description this method fetches all CPA for an account
     * @author garora@rafter.one
     * @param dataMap - Input Param
     * @return Map<String,Object>
     * @created 17 Sep 24
    */
    public static Map<String,Object> getContactPointAddresses(Map<String,Object> dataMap){
        if(dataMap!=null && dataMap.containsKey(SIB_Constants.BILLING_ACCOUNT_ID) && dataMap.get(SIB_Constants.BILLING_ACCOUNT_ID)!=null){
            String addressType = SIB_Constants.ADDRESS_TYPE_BILLING;
            if(dataMap.containsKey(SIB_Constants.ADDRESS_TYPE) && dataMap.get(SIB_Constants.ADDRESS_TYPE)!=null)
            {
                addressType = (String)dataMap.get(SIB_Constants.ADDRESS_TYPE);
            }
            String accountId = (String)dataMap.get(SIB_Constants.BILLING_ACCOUNT_ID);
            List<ContactPointAddress> cpaList = (List<ContactPointAddress>)SIB_AddressSelector.getAddressesByAccountIdsAndAddressType(new List<Id>{accountId},addressType);
            dataMap.put(SIB_Constants.ADDRESSES,cpaList);
        }
        return dataMap;
    }

    /**
     * @description this method upserts CPA and populates address on cart and cart delivery group
     * @author garora@rafter.one
     * @param dataMap - Input Param
     * @return Map<String,Object>
     * @created 17 Sep 24
    */
    public static Map<String,Object> updateCartWithCPA(Map<String,Object> dataMap){
        if(dataMap!=null && dataMap.containsKey(SIB_Constants.CART_ID) && dataMap.get(SIB_Constants.CART_ID)!=null){
            String cartId = (String) dataMap.get(SIB_Constants.CART_ID);
            String strRequest = JSON.serialize(dataMap.get(SIB_Constants.ADDRESS));
            ContactPointAddress cpa = (ContactPointAddress) JSON.deserialize(strRequest,ContactPointAddress.class);
            cpa.Name = UserInfo.getName() + ' ' + SIB_Constants.BILLING_NAME;
            upsert cpa;
            List<ContactPointAddress> shippingCpas = (List<ContactPointAddress>)SIB_AddressSelector.getAddressesByAccountIdsAndAddressType(new List<Id>{cpa.ParentId},SIB_Constants.ADDRESS_TYPE_SHIPPING);
            if(shippingCpas!=null && !shippingCpas.isEmpty())
            {
                dataMap.put(SIB_Constants.SHIPPING_ADDRESSES,shippingCpas);
            }
            List<WebCart> lstWebCart = [SELECT Id,WebStoreId , AccountId , BillingStreet, BillingCity, CartId__c,
                                        BillingStateCode, BillingState, BillingCountry, BillingCountryCode FROM WebCart WHERE Id=:cartId];
            if(lstWebCart!=null && lstWebCart.size()>0)
            {
                WebCart cart = lstWebCart[0];
                cart.BillingCity = cpa.City;
                cart.BillingCountryCode = cpa.CountryCode;
                cart.BillingStateCode = cpa.StateCode;
                cart.BillingStreet = cpa.Street;
                cart.BillingPostalCode = cpa.PostalCode;
                cart.Id = cartId;
                cart.CartId__c = cartId;
                update cart;
            }
            dataMap.put(SIB_Constants.BILLING_ACCOUNT_ID,cpa.ParentId);
            dataMap.put(SIB_Constants.ADDRESS,cpa);
            dataMap.put(SIB_Constants.ADDRESS_TYPE, SIB_Constants.ADDRESS_TYPE_BILLING);
            dataMap = getContactPointAddresses(dataMap);
        }
        return dataMap;
    }

}