import { LightningElement, api } from 'lwc';
import { Labels } from './labels';
import displayOriginalPriceEvaluator from './sibProductPricingUtils';

export default class ProductPricing extends LightningElement {

    static renderMode = 'light';

    @api
    plpConfig;

    @api
    price;

    get layoutClass(){
        return 'col';
    }

    get negotiatedPrice() {
        return this.price?.unitPrice;
    }

    get originalPrice() {
        return this.price?.listPrice;
    }

    get currencyCode() {
        return this.price?.currencyCode;
    }

    get showNegotiatedPrice() {
        return this.plpConfig?.showNegotiatedPrice;
    }

    get showOriginalPrice() {
        return this.plpConfig?.showOriginalPrice;
    }

    get unavailablePriceLabel() {
        return this.plpConfig?.unavailablePriceText;
    }

    get strikethroughAssistiveText() {
        return Labels.strikethroughAssistiveText;
    }

    get displayOriginalPrice() {
        return displayOriginalPriceEvaluator(
            this.showNegotiatedPrice,
            this.showOriginalPrice,
            this.negotiatedPrice,
            this.originalPrice
        );
    }

    get displayNegotiatedPrice() {
        return this.showNegotiatedPrice && this.negotiatedPrice !== undefined && this.negotiatedPrice !== null;
    }

    get displayAssistiveText() {
        return this.displayNegotiatedPrice && this.displayOriginalPrice;
    }

    get isPriceAvailable() {
        return this.showNegotiatedPrice && this.negotiatedPrice !== undefined && this.negotiatedPrice !== null;
    }

    get hasNegotiatedPriceLabel() {
        return !!this.negotiatedPriceLabel;
    }

    get hasOriginalPriceLabel() {
        return !!this.originalPriceLabel;
    }

    
}