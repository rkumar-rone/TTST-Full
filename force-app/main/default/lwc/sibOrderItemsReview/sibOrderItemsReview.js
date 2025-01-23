import { LightningElement, api, wire, track } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import getCartConfiguration from '@salesforce/apex/SIB_CartController.getCartConfiguration';
import getCartDetails from '@salesforce/apex/SIB_CartController.getCartDetails';

export default class SibOrderItemsReview extends LightningElement {
    static renderMode = 'light';
    readOnly= true;
    @api cartItems;
    @api cartDetails;
    @api productCount;
    cartConfig;
    cartTotal;
    mapParams = {
        configType : 'cart'
    };

    @wire(getCartConfiguration, {mapParams : '$mapParams' })
    wiredCartConfig({ error, data }) {
        if (data) {
            let tempConfig = JSON.parse(JSON.stringify(data.cartConfig));
            this.cartConfig = tempConfig;
        } else if (error) {
            console.error(error);
        }
    };
}