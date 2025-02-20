import { LightningElement,api } from 'lwc';

export default class SibProductOverviewTakeCourse extends LightningElement {
    static renderMode = 'light';
        
        @api
        productDetail;
    
        get showDetails() {
            return this.productDetail != null;
        }

        get whyTakeThisCourse() {
            return this.productDetail?.fields?.Why_Take_This_Course__c;
        }
}