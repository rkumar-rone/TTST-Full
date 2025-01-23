import { LightningElement, api, wire } from 'lwc';
import { ProductAdapter } from 'commerce/productApi';
import basePath from '@salesforce/community/basePath';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
const SHOW_PRODUCT_EVT = 'showproduct';
import classCodeText from '@salesforce/label/c.SIB_classCode';
import quantityText from '@salesforce/label/c.SIB_qty';

export default class SibOrderItems extends LightningElement {

    @api orderConfig;
    @api orderDetails;
    @api orderData;
    @api orderItem;
    productId;
    productDetail;

    labels = {
        classCodeText,
        quantityText
    }

    productImage = SIBTheme + '/images/Course-Default-Image.png';

    @wire(ProductAdapter, { productId: '$productId' })
    onGetProductDetails(result)
    {
        if (result.data)
        {
            this.productDetail = result.data;
        }
    }

    get imgUrl(){
        if(this.productDetail?.defaultImage?.url?.includes('default-product-image')) {
            return this.productImage;
        } else {
            if(this.productDetail?.defaultImage?.url?.includes("cms")) {
                return basePath + '/sfsites/c/'+ this.productDetail?.defaultImage?.url;
            }
            return this.productDetail?.defaultImage?.url;
        }
    }

    get currencyCode() {
        return this.orderData?.CurrencyIsoCode;
    }

    get item() {
        return this.orderItem;
    }

    connectedCallback() {
        this.productId = this.item?.Product2Id;
    }

    handleKeydown(evt) {
        if (evt.key === 'Enter') {
            this.handleProductDetailPageNavigation(evt);
        }
    }

    handleProductDetailPageNavigation(event) {
        event.preventDefault();
        const productId = this.item?.productSlugURL != null ? this.item?.productSlugURL : this.productId;

        this.dispatchEvent(
            new CustomEvent(SHOW_PRODUCT_EVT, {
                detail: productId,
            })
        );
    }
}