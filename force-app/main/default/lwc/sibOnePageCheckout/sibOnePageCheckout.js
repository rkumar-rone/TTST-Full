import { LightningElement, api } from 'lwc';

export default class SibOnePageCheckout extends LightningElement {
    static renderMode = "light"; // the default is 'shadow'
    @api checkoutDetails;
    @api checkoutConfig;
}