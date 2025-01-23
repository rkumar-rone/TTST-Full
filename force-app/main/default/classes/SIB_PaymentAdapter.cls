/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 08-13-2024
 * @last modified by  : Gaurav Setia
**/
global with sharing class SIB_PaymentAdapter implements commercepayments.PaymentGatewayAdapter {

    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        try {
            commercepayments.GatewayResponse response;
            Map<String,Object> mapParams = new Map<String,Object>();
            mapParams = SIB_CheckoutService.getCheckoutConfiguration(mapParams);
            if(mapParams.containsKey('checkoutConfig')){
                SIB_CheckoutConfiguration checkoutConfig =  (SIB_CheckoutConfiguration)mapParams.get('checkoutConfig');
                if(String.isNotBlank(checkoutConfig.creditCardGateway)){
                    Map<String,Object> creditCardGatewayClassMap = (Map<String,Object>)checkoutConfig.creditCardGatewayClassMap;
                    if(creditCardGatewayClassMap.containsKey(checkoutConfig.creditCardGateway)){
                        Type paymentType = Type.forName((String)creditCardGatewayClassMap.get(checkoutConfig.creditCardGateway));
                        commercepayments.PaymentGatewayAdapter paymentAdapter = (commercepayments.PaymentGatewayAdapter)paymentType.newInstance();
                        response = paymentAdapter.processRequest(gatewayContext);
                    }else{
                        return new commercepayments.GatewayErrorResponse('400', 'Invalid Checkout Configuration : creditCardGateway Class not found.');
                    }
                }else{
                    return new commercepayments.GatewayErrorResponse('400', 'Invalid Checkout Configuration : creditCardGateway not found.');
                }
            }
            return response;
        } catch (Exception e) {
            return new commercepayments.GatewayErrorResponse('400', e.getMessage());
        }
    }
}