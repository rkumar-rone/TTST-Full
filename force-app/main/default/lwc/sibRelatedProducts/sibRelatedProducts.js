import { LightningElement, api,wire } from 'lwc';
import { AppContextAdapter, getSessionContext } from 'commerce/contextApi';

export default class SibRelatedProducts extends LightningElement {
    static renderMode = 'light';

    @api product;
    @api cartItems;
    @api pageName;
    @api titleField;
    @api descField;
    @api buttonLabel;
    @api productAttr1FieldName;
    @api hideProductAttr1;
    @api productAttr1ImageId;
    
    @api productAttr2FieldName;
    @api hideProductAttr2;
    @api productAttr2ImageId;

    @api productAttr3FieldName;
    @api hideProductAttr3;
    @api productAttr3ImageId;

    @api productImageAttr1FieldName;
    @api hideProductImageAttr1;
    @api productImageAttr1ImageId;

    @api hideAddtoCart; 
    @api brandColor;
    @api imageAttrTagBackColor;
    @api tilePriceColor;
    @api imageAttrTagTextColor;
    @api hideDescription;

    productAttr1Deatils = {};
    productAttr2Deatils = {};
    productAttr3Deatils = {};

    productImageAttr1Details = {};
    productAttrData = [];
    isProductDetailPage = false;
    webstoreId;
    effectiveAccountId;

    @wire(AppContextAdapter)
    hanldeAppContextAdapterResponse(result) {
        if (result.data) {
            this.webstoreId = result.data.webstoreId;
            this.getEffectiveAccountId();
        }
    }

    async getEffectiveAccountId() {
        const result = await getSessionContext();
        if (result) {
            this.effectiveAccountId = result.effectiveAccountId;
            
        }
    }

    connectedCallback() {
        this.isProductDetailPage = this.pageName == "Product Detail Page" ? true : false;
        this.productAttr1Deatils["productAttrFieldName"] = this.productAttr1FieldName;
        this.productAttr1Deatils["hideProductAttr"] = this.hideProductAttr1;
        this.productAttr1Deatils["productAttrImageId"] = this.productAttr1ImageId;

        this.productAttr2Deatils["productAttrFieldName"] = this.productAttr2FieldName;
        this.productAttr2Deatils["hideProductAttr"] = this.hideProductAttr2;
        this.productAttr2Deatils["productAttrImageId"] = this.productAttr2ImageId;

        this.productAttr3Deatils["productAttrFieldName"] = this.productAttr3FieldName;
        this.productAttr3Deatils["hideProductAttr"] = this.hideProductAttr3;
        this.productAttr3Deatils["productAttrImageId"] = this.productAttr3ImageId;

        this.productAttrData.push(
            this.productAttr1Deatils,
            this.productAttr2Deatils,
            this.productAttr3Deatils
        );

        this.productImageAttr1Details["productAttrFieldName"] = this.productImageAttr1FieldName;
        this.productImageAttr1Details["hideProductAttr"] = this.hideProductImageAttr1;
        this.productImageAttr1Details["productAttrImageId"] = this.productImageAttr1ImageId;
    }

    renderedCallback() {
        this.initCSSVariables();
    }
    initCSSVariables() {
        var css = document.body.style;
        css.setProperty("--brand", this.brandColor);
        css.setProperty("--tagPriceColor", this.tilePriceColor);
        css.setProperty("--tagBackgroundColor", this.imageAttrTagBackColor);
        css.setProperty("--tagTextColor", this.imageAttrTagTextColor);
    }
}