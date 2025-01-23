import { LightningElement, api } from 'lwc';

export default class SibProductDetailCancelPolicy extends LightningElement {

    static renderMode = 'light';

    @api
    productDetail;

    get showDetails() {
        return this.productDetail != null && (
            this.productDetail?.fields?.Cancellation_Policy__c != null || 
            this.productDetail?.fields?.Prerequisite__c != null
        );
    }

    get cancelPolicy() {
        return this.productDetail?.fields?.Cancellation_Policy__c;
    }

    get prerequisite() {
        return this.productDetail?.fields?.Prerequisite__c;
    }
}