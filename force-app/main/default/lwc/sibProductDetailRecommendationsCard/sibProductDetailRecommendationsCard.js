import { LightningElement, api } from 'lwc';
import { navigate, NavigationContext, NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import getManagedContentByContentKeys from "@salesforce/apex/Saltbox_CMSConnector.getManagedContentByContentKeys";


export default class SibProductDetailRecommendationsCard extends NavigationMixin(LightningElement) {
    @api product;
    @api hideAddtoCart;
    @api descField;
    @api titleField;
    @api buttonLabel;
    @api hideDescription;
    @api productAttrData;
    @api productImageAttr;

    @api labels;

    mutProductAttrData = [];
    productImageAttrImg;
    mutProductImageAttr = {};

    connectedCallback() {
        for (var i = 0; i < this.productAttrData?.length; i++) {
            var obj = { ...this.productAttrData[i] };
            obj["productAttrValue"] =
                this.product?.fieldsMap[this.productAttrData[i]?.productAttrFieldName];
            this.mutProductAttrData.push(obj);
        }

        this.mutProductImageAttr = { ...this.productImageAttr };
        this.mutProductImageAttr["productAttrValue"] =
        this.product?.fieldsMap[this.mutProductImageAttr.productAttrFieldName];
    }

    handleManagedContentByContentKeys(){
        getManagedContentByContentKeys({
            managedContentIds: this.mutProductImageAttr.productAttrImageId
        })
        .then((data) => {
            if (data) {
                this.getImageData = typeof data == "object" ? data : JSON.parse(data);

                if (this.getImageData.success) {
                    this.productImageAttrImg = this.getImageData.image;
                    this.isLoading = false;
                }
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }
    get shortDescription() {
        return this.product?.fieldsMap[this.descField];
    }


    get productName(){
        return this.product?.fieldsMap[this.titleField];
    }

    get productId(){
        return this.product?.productId;
    }


    get productPrice(){
        return   this.product?.price?.negotiatedPrice;
    }

    get productListPrice(){
        return this.product?.price?.listPrice ;
    }

    get discountedPrice(){
        return this.product?.price?.unitPrice ;
    }

    get strikeTroughPriceClass(){
        return  this.hasDiscount ? 'add-strike-line ' : ' ';
    }

    get currencyCode() {
        return this.product?.price?.currencyCode;
    }

    addToCartAction() {
        let productId = this.product?.productId ;
        this.dispatchEvent(
            new CustomEvent('addtocart', {
                detail: {
                    productId : productId,
                    currencyCode : this.product?.price?.currencyCode
                },
                composed: true,
                bubbles: true,
            })
        );
    }

    get hasDiscount(){
        return this.product?.price?.unitPrice <  this.product?.price?.negotiatedPrice ;
    }

    get discountPercent(){
        const unitPrice = this.product?.price?.unitPrice;
        const negotiatedPrice = this.product?.price?.negotiatedPrice;

        if (unitPrice && negotiatedPrice) {
            const discountAmount = negotiatedPrice - unitPrice;
            const discountPercentage = (discountAmount / negotiatedPrice) * 100;
        return Math.round(discountPercentage) + "%";
        }
    }

    handleNavigation(event){
        let siteUrl = '/product/' + event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: siteUrl
            }
        })
        .then((siteUrl) => {
            window.open(siteUrl,'_self');
        });
    }
}