import { LightningElement, api, track,wire } from 'lwc';
import getRelatedProducts from '@salesforce/apex/SIB_ProductDetailController.getRelatedProducts';
import addCartItem from '@salesforce/apex/SIB_CartController.addCartItem';
import frequentlyBoughtTogether from '@salesforce/label/c.SIB_FrequentlyBoughtTogether';
import addToCartSuccessMsg from '@salesforce/label/c.SIB_AddToCartSuccessMsg';
import addToCartErrorMsg from '@salesforce/label/c.SIB_AddToCartErrorMsg';
import getEverythingYouNeed from '@salesforce/label/c.SIB_GetEverythingYouNeed';
import getEverythingYouNeedHelpText from '@salesforce/label/c.SIB_GetEverythingYouNeedHelpText';
import addToCart from '@salesforce/label/c.SIB_AddToCart';
import classCode from '@salesforce/label/c.SIB_classCode';
import mostPopularName from '@salesforce/label/c.SIB_MostPopularName';

export default class SibRelatedCartContainer extends LightningElement {
    static renderMode = 'light';
   
    showRelated = false;
    isLoading = true
    @track relatedProducts = [];
    @track productIds = [];


    labels = {
        frequentlyBoughtTogether,
        addToCartErrorMsg,
        addToCartSuccessMsg,
        getEverythingYouNeed,
        getEverythingYouNeedHelpText,
        addToCart,
        classCode,
        mostPopularName,
    };

    @api webstoreId;
    @api effectiveAccountId;

    @api
    get cartItems() {
        return this._cartItems;
    }

    set cartItems(value) {
        this.productIds = [];
        this._cartItems = value;
        this._cartItems?.forEach(element => {
            this.productIds.push(element.ProductDetails.productId);
        });
        this.getRelatedProducts();
    }

    @api product;
    @api hideAddtoCart;
    @api descField;
    @api titleField;
    @api buttonLabel;
    @api hideDescription;
    @api productAttrData;
    @api productImageAttr;

    clearRelatedProducts() {
        this.relatedProducts = [];
        this.showRelated = false;
    }

    getRelatedProducts(){
        this.clearRelatedProducts();
        this.isLoading = true;
        let mapParams = {
            productIdList : this.productIds,
            effectiveAccountId : this.effectiveAccountId,
            webstoreId : this.webstoreId
        }
        getRelatedProducts({
            mapParams: mapParams
        }).then((results) => {
            if(results && results?.isSuccess && results?.relatedProductMap)
            {
                let finalResponse = [];
                Object.values(results.relatedProductMap).forEach(eachProd => {
                    finalResponse.push(...eachProd);
                });
                this.relatedProducts =  finalResponse.sort((a, b) => a.order - b.order);
                if (this.relatedProducts.length > results?.noOfRecommendations) {
                    this.relatedProducts = this.relatedProducts.slice(0, results.noOfRecommendations);
                }
                this.showRelated = true;
            }
            this.isLoading = false;
        }).catch((error) => {
            console.log(error);
            this.isLoading = false;

        });
    }

    addToCartAction(event) {
        this.isLoading = true;
        let productId = event.detail.productId;
        let productQuantity = 1;
        if (productId && productQuantity && productQuantity > 0) {

            let mapParams = {
                webstoreId: this.webstoreId,
                effectiveAccountId: this.effectiveAccountId,
                productId: productId,
                quantity: productQuantity,
                currencyISOCode: event.detail.currencyCode

            };
            addCartItem({
                'mapParams' : mapParams
            }).then((result) => {
                if(result?.isSuccess) {
                    this.querySelector('c-sib-show-toast-message').showToast(this.labels.addToCartSuccessMsg,'success',5000);
                    this.dispatchEvent(
                        new CustomEvent('recommendationaddtocart', {
                            composed: true,
                            bubbles: true,
                        })
                    );
                } else {
                    this.querySelector('c-sib-show-toast-message').showToast(this.labels.addToCartErrorMsg,'error',5000);
                }
                this.isLoading = false;
            }).catch((err) => {
                this.isLoading = false;
                this.querySelector('c-sib-show-toast-message').showToast(this.labels.addToCartErrorMsg,'error',5000);
                console.log(err);
            });
        }
    }
}