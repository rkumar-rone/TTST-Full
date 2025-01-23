import { LightningElement, api, wire } from 'lwc';

export default class SibMultiStepCheckout extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api checkoutDetails;
    @api checkoutConfig;
    @api cartDetails; //GArora - 17 Sep 2024
    currentState = 'groupOrders';//prev:shipping change by VRa 10 Sep 24
    stateList = ['groupOrders', 'billing', 'payment', 'placeOrder']; // added groupOrders VRa 10 Sep 24, added billing GArora 17 Sep 24
    showGroupOrders = true; //Added by VRa 10 Sep 24
    showBilling = true; //Added by GArora 17 Sep 2024
    showPayment = true;
}