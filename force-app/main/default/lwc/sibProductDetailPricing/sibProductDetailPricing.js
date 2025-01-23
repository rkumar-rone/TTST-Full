import { LightningElement,api,track } from 'lwc';

export default class SibProductDetailPricing extends LightningElement {

    static renderMode = 'light';

    @api 
    productDetail;

    @api
    eventSessions;

    @api
    selectedSessionsJson;

    connectedCallback(){
        window.addEventListener('selectionevent', this.handleSelectionEvent.bind(this));
    }

    disconnectedCallback(){
        window.removeEventListener('selectionevent', this.handleSelectionEvent.bind(this));
    }

    get currencyCode() {
        return this.productDetail?.price?.currencyCode;
    }

    get hasPrice() {
        return this.productDetail?.price?.negotiatedPrice > 0;
    }

    get isEarlyBird() {
        var currentDate = new Date(); 
        var currentTime = currentDate.getTime();
        var deadlineDate = new Date(this.productDetail?.fieldsMap?.Early_Bird_Deadline_formula__c);
        var deadline = deadlineDate.getTime();
        if(deadline > currentTime) {
            return true;
        }
    }

    get selectedSessionPrice(){
        return (this.selectedSessionsJson != null ? (Object.keys(JSON.parse(this.selectedSessionsJson)).length) : 0) * (this.isEarlyBird ? this.sessionEarlyBirdPrice : this.negotiatedPrice);//TATLB-200 Changed 25,Oct 2024 VRa
    }

    get fullRegistrationPrice(){
        return (this.eventSessions ? this.eventSessions?.length : 1) * this.negotiatedPrice;
    }

    get fullEarlyBirdPrice(){
        return this.productDetail?.price?.earlyBirdRegistrationCost;
    }

    get sessionEarlyBirdPrice(){
        return this.productDetail?.price?.earlyBirdSessionPrice;
    }

    get negotiatedPrice() {
        return this.productDetail?.price?.negotiatedPrice;
    }

    get isAllEventsAreRequired(){
        if(this.eventSessions && this.eventSessions.length > 0){
            return this.eventSessions.every(session => session.Required__c == true);
        }
    }

    handleSelectionEvent(evt) {
        if(evt.detail){
            this.selectedSessionsJson = evt.detail.selectedSessionsJson 
        }
    }
}