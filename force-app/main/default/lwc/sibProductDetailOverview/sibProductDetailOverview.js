import { LightningElement, api } from 'lwc';

/**
 * @slot slot1 
 * @slot slot2 
 * @slot slot3
 * @slot slot4
 * @slot slot5
 * @slot slot6
 * @slot slot7
 * @slot slot8
 * @slot slot9
 * @slot slot10
 */

export default class SibProductDetailOverview extends LightningElement {

    static renderMode = 'light';

    @api
    productDetail;

    // get showDetails() {
    //     return this.productDetail != null;
    // }

    // get whyTakeThisCourse() {
    //     return this.productDetail?.fields?.Why_Take_This_Course__c;
    // }

    // get productOverviewUrl() {
    //     return this.productDetail?.fields?.SIB_Vimeo_Overview_URL__c;
    // }

    // get whoIsThisCourseFor() {
    //     return this.productDetail?.fields?.Who_is_this_course_for__c;
    // }
}