import { LightningElement,api } from 'lwc';

export default class SibProductOverviewWhoisCourse extends LightningElement {
    static renderMode = 'light';
            
            @api
            productDetail;
        
            get showDetails() {
                return this.productDetail != null;
            }
    
            get whoIsThisCourseFor() {
                return this.productDetail?.fields?.Who_is_this_course_for__c;
            }
}