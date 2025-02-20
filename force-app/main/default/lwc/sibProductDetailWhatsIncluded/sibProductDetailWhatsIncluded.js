import { LightningElement, api } from 'lwc';
import getEventRelationshipChildNames from '@salesforce/apex/SIB_ProductDetailController.getEventRelationshipChildNames';


export default class SibProductDetailWhatsIncluded extends LightningElement {

    static renderMode = 'light';
    isSkeletonLoading = true;
    bundleChildDetails = [];

    @api
    get productDetail() {
        return this._productDetail;
    }
    set productDetail(value) {
        this._productDetail = value;
        if(value && value?.fields?.Product_Group__c == 'Bundle') {
            this.fetchChildData(value);
        }
    }

    get showDetails() {
        return this.productDetail != null;
    }

    get whatsIncludedOrTopicCovered() {
        return this.whatsIncluded || this.topicCovered;
    }

    get whatsIncluded() {
        return this.productDetail?.fields?.What_s_Included_in_the_CostRT__c;
    }

    get agenda() {
        return this.productDetail?.fields?.Agenda__c;
    }

    get learningObjectives(){
        return this.productDetail?.fields?.Learning_Objectives__c;
    }

    get topicCovered() {
        return this.productDetail?.fields?.Topics_Covered__c;
    }

    get whatYouAllNeed(){
        return this.productDetail?.fields?.What_You_ll_NeedRT__c;
    }

    get isBundleProduct(){
        return this.productDetail?.fields?.Product_Group__c == 'Bundle' ;
    }

    get isCollevaProduct(){
        return this.productDetail?.fields?.Colleva_Product__c;
    }

    get isSelfStudy(){
        return this.productDetail?.fields?.Product_Group__c == 'Self-Study' ;
    }

    get isPublicProduct(){
        return this.productDetail?.fields?.Product_Group__c == 'Public Course' 
    }

    get hoursOfVideoContent() {
        return Number(this.productDetail?.fields?.SIB_Hours_of_Video_Content__c);
    }

    get hoursToComplete() {
        return Number(this.productDetail?.fields?.SIB_Hours_to_Complete__c);
    }

    fetchChildData(value) {
        let  mapParams = { productId: value?.id };

        getEventRelationshipChildNames({ mapParams })
            .then((result) => {
                if (result && result?.bundleChildProductDetails) {
                    this.bundleChildDetails = result?.bundleChildProductDetails;
                    let childNames = [];

                    if (this.bundleChildDetails) {
                        childNames = this.bundleChildDetails?.map(child => child.Name);
                    }

                    this.dispatchEvent(new CustomEvent('sendChildNames', 
                        {
                        detail: {
                            childProductNames : childNames
                        },
                        bubbles: true,
                        composed: true
                        })
                    );
                } else {
                    this.bundleChildDetails = [];
                }
                this.isSkeletonLoading = false;
            })
            .catch((error) => {
                this.isSkeletonLoading = false;
                console.log('Error fetching child names:', error);
            });
    }

    _productDetail;
}