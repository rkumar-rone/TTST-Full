import { LightningElement, api } from 'lwc';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';

export default class SibProductDetailCertificate extends LightningElement {
    static renderMode = 'light';

    certImage = SIBTheme + '/images/tts-certification.png';

    @api
    productDetail;

    get showDetails() {
        return this.productDetail != null && (
            this.productDetail?.fields?.SIB_Certificate_Title__c != null ||
            this.productDetail?.fields?.SIB_Certificate_Description__c != null
        );
    }

    get certTitle() {
        return this.productDetail?.fields?.SIB_Certificate_Title__c;
    }

    get certDescription() {
        return this.productDetail?.fields?.SIB_Certificate_Description__c;
    }
}