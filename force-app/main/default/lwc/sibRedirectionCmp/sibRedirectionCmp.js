import { LightningElement,api } from 'lwc';
import isGuestUser from "@salesforce/user/isGuest";
import basePath from '@salesforce/community/basePath';
import SIB_LWRSiteURL from '@salesforce/label/c.SIB_LWRSiteURL';
import SIB_HomePageUrl from '@salesforce/label/c.SIB_HomePageUrl';

export default class SibRedirectionCmp extends LightningElement {
    @api url;
    @api redirectToHome;
    processingMessage = 'Loading';

    isShowSpinner = this.isInSitePreview() ? false : true;

    connectedCallback() {
        if(!this.isInSitePreview()) {
            const loc = window.location.href;
            if(this.redirectToHome) {
                if(!isGuestUser && this.url) {
                    window.location.href = this.url;
                    this.isShowSpinner = false;
                } else {
                    window.location.href = SIB_HomePageUrl;
                }
            } else {
                if(loc.includes('orderNumber') && loc.includes('OrderLookup')){
                    const urlParams = new URLSearchParams(loc.slice(loc.indexOf('?')));
                    const orderSummaryId = urlParams.get('orderNumber');
                    window.location.href = basePath + '/OrderSummary/' + orderSummaryId;
                } else if(loc?.includes('home/home.jsp')){
                    window.location.href = SIB_HomePageUrl;
                } else if(loc?.includes('/s/')) {
                    let url = loc?.split('/s/');
                    window.location.href = SIB_LWRSiteURL + '/' + url[1];
                } else if(this.url) { 
                    window.location.href = this.url;
                    this.isShowSpinner = false;
                } else {
                    this.isShowSpinner = false;
                }
            }
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