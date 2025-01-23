import { LightningElement, wire } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';
import preserveGuestCart from '@salesforce/apex/SIB_CartController.preserveGuestCart';
import compareCurrency from '@salesforce/apex/SIB_CartController.compareCurrency';
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import SIB_LWRSiteURL from '@salesforce/label/c.SIB_LWRSiteURL';
import {consoleLogging} from "c/sibUtils";

export default class SibStrivacityRedirection extends NavigationMixin(LightningElement) {

    static renderMode = "light"; // the default is 'shadow'
    url;
    isShowSpinner = !this.isInSitePreview();
    spinnerMsg = 'Processing';
    isCartAvailable;
    webstoreId;
    effectiveAccountId;
    cartId;

    labels = {
        SIB_LWRSiteURL
    }

    @wire(AppContextAdapter)
    handleAppContextAdapterResponse(result){
        consoleLogging('handleAppContextAdapterResponse => ', result);
        if(result.data)
        {
            this.webstoreId = result.data.webstoreId;
            this.getEffectiveAccountId();
        }
    }

    async getEffectiveAccountId(){
        const result = await getSessionContext();
        consoleLogging('getEffectiveAccountId => ', result);
        if(result)
        {
            this.effectiveAccountId = result.effectiveAccountId;
            consoleLogging('preserveGuestCart checkCurrency');
            await this.checkCurrency();
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if(currentPageReference && !this.isInSitePreview())
        {
            this.url = '/' + currentPageReference?.state?.page;
            this.isCartAvailable = currentPageReference?.state?.preserveCart;
            if(this.isCartAvailable === 'true')
            {
                this.cartId = currentPageReference?.state?.cartId;
            }
        }
    }

    async preserveGuestCart() {
        if(this.webstoreId && this.effectiveAccountId)
        {
            let mapParams = {
                webstoreId: this.webstoreId,
                effectiveAccountId: this.effectiveAccountId,
                cartId: this.cartId,
                isCheckoutPage: this.url?.includes('checkout')
            };
            await preserveGuestCart({'mapParams': mapParams})
                .then((result) => {
                    consoleLogging('preserveGuestCart result', result);
                    if (result?.isSuccess) {
                        consoleLogging('preserveGuestCart if');
                        this.handleNavigation();
                    } else {
                        consoleLogging('preserveGuestCart else');
                        this.handleCheckoutUrl();
                        this.handleNavigation();
                    }
                })
                .catch((e) => {
                    this.handleCheckoutUrl();
                    this.handleNavigation();
                    consoleLogging('preserveGuestCart exception', e);
                })
                .finally(() => {

                });
        }
    }

    async checkCurrency() {
        if(this.webstoreId && this.effectiveAccountId) {
            let mapParams = {
                effectiveAccountId: this.effectiveAccountId,
                cartId: this.cartId
            };
            await compareCurrency({'mapParams': mapParams})
                .then((result) => {
                    consoleLogging('compareCurrency result', result);
                    if (result?.isSuccess) {
                        consoleLogging('compareCurrency if');
                        this.preserveGuestCart();
                    } else {
                        this.handleCheckoutUrl();
                        this.handleNavigation();
                        consoleLogging('compareCurrency else');
                    }
                })
                .catch((e) => {
                    this.handleCheckoutUrl();
                    this.handleNavigation();
                    consoleLogging('compareCurrency exception', e);
                })
                .finally(() => {
    
                });
        }
    }

    handleNavigation() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: this.labels.SIB_LWRSiteURL + '/en-US' + this.url
            }
        }).then((url) => {
            window.open(url, '_self');
        });
    }

    handleCheckoutUrl() {
        if(this.url?.includes('checkout'))
        {   //To handle no cart creation
            this.url = this.url.replace('checkout', 'cart');
        }
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