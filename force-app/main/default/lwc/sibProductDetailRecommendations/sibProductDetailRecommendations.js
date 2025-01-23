import { LightningElement,api, wire } from 'lwc';
import getRelatedProducts from '@salesforce/apex/SIB_ProductDetailController.getRelatedProducts';
import addCartItem from '@salesforce/apex/SIB_CartController.addCartItem';
import { refreshCartSummary } from "commerce/cartApi";
import addToCartSuccessMsg from '@salesforce/label/c.SIB_AddToCartSuccessMsg';
import addToCartErrorMsg from '@salesforce/label/c.SIB_AddToCartErrorMsg';
import getEverythingYouNeed from '@salesforce/label/c.SIB_GetEverythingYouNeed';
import getEverythingYouNeedHelpText from '@salesforce/label/c.SIB_GetEverythingYouNeedHelpText';
import addToCart from '@salesforce/label/c.SIB_AddToCart';
import save from '@salesforce/label/c.SIB_Save';

export default class SibProductDetailRecommendations extends LightningElement {
    @api recordId;
    static renderMode = 'light';
    _productDetails;
    _variantState;
    isLoading = false
    relatedProductId = ''
    relatedProducts ;

    labels = {
        addToCartErrorMsg,
        addToCartSuccessMsg,
        getEverythingYouNeed,
        getEverythingYouNeedHelpText,
        addToCart,
        save
    };

    @api webstoreId;
    @api effectiveAccountId;
    @api hideAddtoCart;
    @api descField;
    @api titleField;
    @api buttonLabel;
    @api hideDescription;
    @api productAttrData;
    @api productImageAttr;

    @api
    get product() {
        return this._productDetails;
    }

    set product(val) {
        this._productDetails = val;
        this.variantProductIds = [];
        if (val?.variationParentId === undefined && val?.id) // simple or parent 
        {
            this.relatedProductId = val?.id;
            this.variantProductIds.push(val?.id);
        } else if(val && val?.variationParentId) // child 
        {
            this.relatedProductId = val?.variationParentId;
            this.variantProductIds.push(val?.variationParentId);
        }
        const mappings = val?.variationInfo?.attributesToProductMappings || [];

        mappings.forEach(value => {
            if (value?.productId) {
                this.variantProductIds.push(value.productId); // store simple / parent / child ids
            }
        });

        this.getRelatedProducts();
    }

    getRelatedProducts(){
        this.isLoading = true;
        let mapParams = {
            productIdList : this.variantProductIds,
            webstoreId : this.webstoreId,
            effectiveAccountId : this.effectiveAccountId
        }
        getRelatedProducts({
            mapParams: mapParams
        }).then((results) => {
            if (results?.isSuccess && results?.relatedProductMap) {
                
                let relatedRes = results?.relatedProductMap[this.relatedProductId];
            
                if (Array.isArray(relatedRes) && relatedRes.length > 1) {
                    this.relatedProducts = relatedRes.sort((a, b) => a.order - b.order);
                } 
                else{
                    this.relatedProducts = relatedRes;
                }
            
                if (this.relatedProducts.length > results?.noOfRecommendations) {
                    this.relatedProducts = this.relatedProducts.slice(0, results?.noOfRecommendations);
                }
            }
            this.isLoading = false;
            
        }).catch((error) => {
            this.isLoading = false
            console.log(error);
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
                if(result.isSuccess) {
                    this.sendBubbledToastMessage(this.labels.addToCartSuccessMsg,'success',5000);
                    refreshCartSummary();
                } else {
                    this.sendBubbledToastMessage(this.labels.addToCartErrorMsg,'error',5000);
                }
                this.isLoading = false;
            }).catch((err) => {
                this.isLoading = false;
                this.sendBubbledToastMessage(this.labels.addToCartErrorMsg,'error',5000);
                console.log(err);
            });
        }
    }

    sendBubbledToastMessage(message, type, duration) {
        let displayDuration = duration && duration > 6000 ? duration : 6000;
        window.dispatchEvent(new CustomEvent("bubbledtoastmessage", {
                detail: {
                    message: message, 
                    type: type,
                    duration: displayDuration
                },
                bubbles: true,
                composed: true
            })
        );
    }
}