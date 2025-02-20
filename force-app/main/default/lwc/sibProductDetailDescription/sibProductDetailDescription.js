import { LightningElement, api } from 'lwc';
import LocationLabel from '@salesforce/label/c.SIB_Location';
import VirtualEventLabel from '@salesforce/label/c.SIB_Virtual_Event';
import getEventRelationshipChildNames from '@salesforce/apex/SIB_ProductDetailController.getEventRelationshipChildNames';

export default class SibProductDetailDescription extends LightningElement {

    static renderMode = 'light';

    labels = {
        LocationLabel,
        VirtualEventLabel
    }

    bundleChildNames = [];

    @api
    get productDetail() {
        return this._productDetail;
    }
    set productDetail(value) {
        this._productDetail = value;
    }

    get isNonParent(){
        return this.productDetail?.productClass !='VariationParent' 
    } 

    get parentPrice(){
        return this.productDetail?.fields?.SIB_PC_Parent_Price__c;
    }

    get isBundleProduct(){
        return this.productDetail?.fields?.Product_Group__c == 'Bundle' 
    }

    get isPublicProduct(){
        return this.productDetail?.fields?.Product_Group__c == 'Public Course' 
    }

    get whatsIncluded() {
        return this.productDetail?.fields?.What_s_Included_in_the_CostRT__c;
    }

    get isSelfStudyProduct(){
        return this.productDetail?.fields?.Product_Group__c == 'Self-Study';
    }

    get isCollevaProduct(){
        return this.productDetail?.fields?.Colleva_Product__c;
    }

    get showDetails() {
        return this.productDetail != null;
    }

    get productSku() {
        return this.productDetail?.fields?.StockKeepingUnit;
    }

    get productName() {
        return this.productDetail?.fields?.Online_Event_Name_formula__c;
    }

    get topicCovered() {
        return this.productDetail?.fields?.Topics_Covered__c;
    }

    get productDeliveryFormat() {
        return this.productDetail?.fields?.Delivery_Format__c;
    }

    get isFormatInPerson() {
        return this.productDetail?.fields?.Delivery_Format__c?.includes('person');
    }

    get trainingLocationName(){
        return this.productDetail?.fields?.Training_Location_Name_formula__c;
    }

    get trainingLocationStreet(){
        return this.productDetail?.fields?.Training_Location_Street_formula__c;
    }

    get trainingLocationCity(){
        return this.productDetail?.fields?.Training_Location_City_formula__c;
    }

    get trainingLocationState(){
        return this.productDetail?.fields?.Training_Location_State_formula__c;
    }

    get trainingLocationCountry(){
        return this.productDetail?.fields?.Training_Location_Country_formula__c;
    }

    get trainingLocationZip(){
        return this.productDetail?.fields?.Training_Location_Zip_Code_formula__c;
    }

    get hoursOfVideoContent() {
        return Number(this.productDetail?.fields?.SIB_Hours_of_Video_Content__c);
    }

    get hoursToComplete() {
        return Number(this.productDetail?.fields?.SIB_Hours_to_Complete__c);
    }

    get showListPrice() {
        return this.listPrice > this.unitPrice;
    }

    get listPrice() {
        return this._listPrice;
    }

    set listPrice(val) {
        this._listPrice = val;
    }

    get unitPrice() {
        return this._unitPrice;
    }

    set unitPrice(val) {
        this._unitPrice = val;
    }

    get currencyCode() {
        return this._currencyCode;
    }

    set currencyCode(val) {
        this._currencyCode = val;
    }

    get totalDays() {
        return this._totalDays;
    }

    set totalDays(val) {
        this._totalDays = val;
    }

    get courseCount() {
        return this._courseCount;
    }

    set courseCount(val) {
        this._courseCount = val;
    }

    get showUnitPrice() {
        return this.unitPrice || this.unitPrice === 0;
    }

    get totalDaysForPc(){
        const days = Number(this.productDetail?.fields?.SIB_PC_Total_Days__c);
        if (days) {
            return days == 1 ? '1 Day' : `1-${days} Days`;
        }
        return null;
    }

    connectedCallback() {
        window.addEventListener('productdata', this.handleProductData.bind(this));
        window.addEventListener('sendChildNames', this.handleChildNames.bind(this));

    }

    disconnectedCallback() {
        window.removeEventListener('productdata', this.handleProductData.bind(this));
        window.removeEventListener('sendChildNames', this.handleChildNames.bind(this));
    }

    handleChildNames(payload){
        this.bundleChildNames = payload.detail.childProductNames
    }

    handleProductData(msg) {
        if(msg && msg.detail) {
            this.listPrice = msg.detail.params.listPrice;
            this.unitPrice = msg.detail.params.unitPrice;
            this.currencyCode = msg.detail.params.currencyCode;
            this.totalDays = msg.detail.params.totalDays;
            this.courseCount = msg.detail.params.courseCount;            
        }
    }

    _totalDays
    _courseCount
    _currencyCode;
    _unitPrice;
    _listPrice;
    _productDetail;
}