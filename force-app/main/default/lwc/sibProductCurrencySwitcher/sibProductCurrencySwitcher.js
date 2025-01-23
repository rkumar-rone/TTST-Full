import { LightningElement, api, wire } from 'lwc';
import { CartSummaryAdapter, refreshCartSummary } from "commerce/cartApi";
import cartApi from 'commerce/cartApi';
import basePath from '@salesforce/community/basePath';
import isGuestUser from "@salesforce/user/isGuest";
import CommonModal from 'c/sibCommonModal';
import SIB_LWRSiteURL from '@salesforce/label/c.SIB_LWRSiteURL';
import SIB_Currency_Change_Msg from '@salesforce/label/c.SIB_Currency_Change_Msg';

import {consoleLogging} from "c/sibUtils";

export default class SibProductCurrencySwitcher extends LightningElement {

    static renderMode = 'light';

    labels = {
        SIB_LWRSiteURL,
        SIB_Currency_Change_Msg
    };

    @api
    productDetail;
    totalProductCount = 0;
    cartCurrency;
    cartId;
    firstLoad = true;

    get showDetails() {
        return this.productDetail != null;
    }

    get productCurrency() {
        return this.productDetail?.fields?.CurrencyIsoCode;
    }

    @wire(CartSummaryAdapter, {})
    CartAdapterFunc({error, data}){
        if (!this.isInSitePreview()){
            if (data) {
                this.totalProductCount = parseInt(data?.totalProductCount); 
                this.cartCurrency = data?.currencyIsoCode;
                this.cartId = data?.cartId;
                this.showCurrencyChangeModal();
            } else if (error) {
                this.totalProductCount = 0;
                this.setUrl();
                consoleLogging("CartAdapter Error: ", error);
            }
        }
    }

    setUrl() {
        consoleLogging('setUrl');
        if(isGuestUser && !this.isInSitePreview() && this.productDetail != null) {
            let url = window?.location?.href;
            if(this.productCurrency === 'GBP' && !url.includes('en-GB')) {
                let newUrl = url.split(this.labels.SIB_LWRSiteURL + '/');
                consoleLogging('setUrl : if block');
                consoleLogging('setUrl : redirect url' + this.labels.SIB_LWRSiteURL + '/en-GB/' + newUrl[1]);
                window.location.href = this.labels.SIB_LWRSiteURL + '/en-GB/' + newUrl[1];
            } else if(this.productCurrency === 'USD' && url.includes('en-GB')) {
                let newUrl = url.split('/en-GB/');
                consoleLogging('setUrl : else if block');
                consoleLogging('setUrl : redirect url' + newUrl[0] + '/en-US/' + newUrl[1]);
                window.location.href = newUrl[0] + '/en-US/' + newUrl[1];
            }
        }
    }

    showCurrencyChangeModal() {
        consoleLogging('showCurrencyChangeModal');
        if(this.cartCurrency && this.productCurrency && this.totalProductCount && this.cartCurrency != this.productCurrency && this.totalProductCount > 0 && this.firstLoad) {
            consoleLogging('this.cartCurrency' + this.cartCurrency);
            consoleLogging('this.productCurrency' + this.productCurrency);
            consoleLogging('this.totalProductCount' + this.totalProductCount);
            consoleLogging('this.firstLoad' + this.firstLoad);
            consoleLogging('showCurrencyChangeModal if block');
            CommonModal.open({
                label: this.labels.SIB_Currency_Change_Msg,
                size: 'small',
                secondaryActionLabel: 'Yes',
                primaryActionLabel: 'No',
                onsecondaryactionclick: () => this.handleCartDelete(),
                onprimaryactionclick: () => this.onNoModal()
            });
            
            this.firstLoad = false;
        }
    }

    handleCartDelete() {
        consoleLogging('handleCartDelete');
        const result = cartApi.deleteCurrentCart();
        result.then((response) => {
            consoleLogging('Cart Delete');
            refreshCartSummary();
            this.setUrl();
        }).catch((error) => {
            consoleLogging('handleCartDelete' + error);
        });
    }

    onNoModal() {
        consoleLogging('onNoModal');
        window.location.href = basePath + '/cart';
        //this.setUrl();
    }

    connectedCallback() {
    }

    isInSitePreview() {
        let url = document.URL;
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }
}