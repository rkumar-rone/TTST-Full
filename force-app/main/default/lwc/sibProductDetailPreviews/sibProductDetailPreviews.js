import { LightningElement, api } from 'lwc';

export default class SibProductDetailPreviews extends LightningElement {

    static renderMode = 'light';

    @api
    productDetail;

    get showDetails() {
        return this.productDetail != null && (
            this.productDetail?.fields?.SIB_Vimeo_Preview1_URL__c != null ||
            this.productDetail?.fields?.SIB_Vimeo_Preview2_URL__c != null
        );
    }

    get preview1Title() {
        return this.productDetail?.fields?.SIB_Vimeo_Preview1_Title__c;
    }

    get preview1Url() {
        return this.productDetail?.fields?.SIB_Vimeo_Preview1_URL__c;
    }

    get preview2Title() {
        return this.productDetail?.fields?.SIB_Vimeo_Preview2_Title__c;
    }

    get preview2Url() {
        return this.productDetail?.fields?.SIB_Vimeo_Preview2_URL__c;
    }
    
}