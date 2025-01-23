import { LightningElement, api } from 'lwc';
import { calculateReviewStars } from 'c/sibUtils';
import basePath from '@salesforce/community/basePath';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';

export default class SibProductDetailHeader extends LightningElement {

    static renderMode = 'light';

    productImage = SIBTheme + '/images/Course-Default-Image.png';

    @api
    productDetail;

    get showDetails() {
        return this.productDetail != null;
    }

    get productName(){
        return this.productDetail?.fields?.Online_Event_Name_formula__c;
    }

    get shortDescription(){
        return this.productDetail?.fields?.Short_Description__c;
    }

    get description(){
        return this.productDetail?.fields?.Description;
    }

    get defaultImage() {
        let defaultImage = Object.assign({}, this.productDetail?.defaultImage);
        if(defaultImage ) {
            defaultImage.url = window.iscmsImageURL(basePath, defaultImage.url);
            if(defaultImage.url.includes('default-product-image')) {
                defaultImage.url = this.productImage;
            }
        }
        return defaultImage;
    }

    rating;
    reviews;
    stars=[];

    get hoursOfVideoContent() {
        return Number(this.productDetail?.fields?.SIB_Hours_of_Video_Content__c);
    }

    get hoursToComplete() {
        return Number(this.productDetail?.fields?.SIB_Hours_to_Complete__c);
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

    get showReview(){
        return this.stars.length>0;
    }

    get isParent(){
        return this.productDetail?.productClass =='VariationParent' 
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
        window.addEventListener('ratingreviews', this.handleRatingReviews.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('productdata', this.handleProductData.bind(this));
        window.removeEventListener('ratingreviews', this.handleRatingReviews.bind(this));
    }

    handleProductData(msg) {
        if(msg && msg.detail) {
            this.totalDays = msg.detail.params.totalDays;
            this.courseCount = msg.detail.params.courseCount;            
        }
    }

    handleRatingReviews(msg){
        if(msg && msg.detail){
            this.rating = parseFloat(msg.detail.rating).toFixed(1);
            if(this.rating){
                this.stars = calculateReviewStars(this.rating);
            }
            this.reviews = msg.detail.reviews;
        }
    }

    _totalDays
    _courseCount
}