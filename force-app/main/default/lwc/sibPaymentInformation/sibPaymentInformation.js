import { LightningElement, api } from 'lwc';

//apex
import getAuthorizationInformation from '@salesforce/apex/SIB_CybersourceController.getAuthorizationInformation';
import revertAuthorization from '@salesforce/apex/SIB_CybersourceController.revertAuthorization';

import SIB_LBL_PAYMENTINFORMATION from '@salesforce/label/c.SIB_PaymentInformation';
import SIB_LBL_MASKEDCARDDIGITS from '@salesforce/label/c.SIB_MaskedCardDigits';
import SIB_LBL_TYPE from '@salesforce/label/c.SIB_Type';
import SIB_LBL_REMOVE from '@salesforce/label/c.SIB_remove';
import SIB_LBL_CARDREMOVEDADDNEWCARD from '@salesforce/label/c.SIB_CardRemovedAddNewCard';
import SIB_LBL_COULDNOTREMOVECARD from '@salesforce/label/c.SIB_CouldNotRemoveCard';
import SIB_LBL_CARD from '@salesforce/label/c.SIB_Card';

export default class SibPaymentInformation extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'


    @api cartSummary = {};
    @api paymentmethodId = '';
    @api paymentgroupId = '';


    //text 
    cardLastFour = '';
    cardType = '';
    paymentAuthorizationId = '';

    //boolean 
    isStencilLoading = true;


    //labels
    labels = {
        SIB_LBL_PAYMENTINFORMATION,
        SIB_LBL_MASKEDCARDDIGITS,
        SIB_LBL_TYPE,
        SIB_LBL_REMOVE,
        SIB_LBL_CARDREMOVEDADDNEWCARD,
        SIB_LBL_COULDNOTREMOVECARD,
        SIB_LBL_CARD
    }

    connectedCallback( ){ 
        
        this.fetchAuthorizationInfo() ;
    }

    stageAction(checkoutStage) {
        
        switch (checkoutStage) {
            case 'CHECK_VALIDITY_UPDATE':
                {
                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'REPORT_VALIDITY_SAVE':
                {

                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'BEFORE_PAYMENT':
                {
                     //Payment component Hidden, allow Place Order
                    return Promise.resolve(true);
                }
                
            case 'PAYMENT':
                {
                    //Payment component Hidden, allow Place Order
                    return Promise.resolve(true)
                }
                
            default:
                return Promise.resolve(true);
        }
    }

    fetchAuthorizationInfo() {
        
        if(this.paymentgroupId && this.paymentmethodId ) {

            getAuthorizationInformation({requestMap: {paymentMethodId : this.paymentmethodId, 
                paymentGroupId: this.paymentgroupId}}).then(result => {

                    if(result && result?.isSuccess && result?.responseData) {
                        
                        this.cardLastFour = result?.responseData?.PaymentMethod?.PaymentMethodDetails;
                        this.cardType = result?.responseData?.PaymentMethod?.PaymentMethodType;
                        this.paymentAuthorizationId = result?.responseData?.Id;
                        this.isStencilLoading = false;
                    } else {
                        
                        this.isStencilLoading = false;
                    }
            }).catch(err => {
                this.isStencilLoading = false;
            })
        }
    }

    revertAuthorization() {
        this.isStencilLoading = true;
        if(this.paymentAuthorizationId && this.cartSummary && this.cartSummary?.cartId) {

            revertAuthorization({requestMap: {paymentAuthorizationId: this.paymentAuthorizationId,
                cartId: this.cartSummary?.cartId}}).then(result => {
                    
                    this.isStencilLoading = false;
                    if(result && result?.isSuccess) {
                    
                        this.showToastMessage(this.labels.SIB_LBL_CARDREMOVEDADDNEWCARD, 'success');
                        this.updatePaymentComponent();
                    }
                }).catch(err =>{
                    this.showToastMessage(this.labels.SIB_LBL_COULDNOTREMOVECARD, 'error');
                    this.isStencilLoading = false;
                    
                });
        } else {
            this.isStencilLoading = false;
        }
    }

    updatePaymentComponent() {
        const paymentUpdateEvent = new CustomEvent("paymentupdated", { detail: true });
        this.dispatchEvent(paymentUpdateEvent);
    }

    showToastMessage(message,type) {
        
        let field = this.querySelector('c-sib-show-toast-message');
        
        field.showToast(message,type,50000);
    }

}