import { LightningElement,api } from 'lwc';

export default class SibProductDetailOverviewVideo extends LightningElement {
    static renderMode = 'light';
    
        @api
        productDetail;
    
        get showDetails() {
            return this.productDetail != null;
        }

        get productOverviewUrl() {
            return this.productDetail?.fields?.SIB_Vimeo_Overview_URL__c;
        }

}