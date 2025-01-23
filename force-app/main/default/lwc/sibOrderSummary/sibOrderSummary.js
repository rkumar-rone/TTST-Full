import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import orderSummaryText from '@salesforce/label/c.SIB_OrderSummary';
import subTotalText from '@salesforce/label/c.SIB_Subtotal';
import taxesText from '@salesforce/label/c.SIB_taxes';
import discountsText from '@salesforce/label/c.SIB_discounts';
import totalText from '@salesforce/label/c.B2B_Mini_Cart_Total';
import continueShoppingText from '@salesforce/label/c.SIB_ContinueShopping';
import publicCourseCategory from '@salesforce/label/c.SIB_PublicCourseCategory';
import selfStudyCategoryApi from '@salesforce/label/c.SIB_SelfStudyBuilderPageApi';
import productsText from '@salesforce/label/c.SIB_products';

export default class SibOrderSummary extends NavigationMixin(LightningElement) {

    @api orderConfig;
    @api orderDetails;
    @api orderData;
    @api showSubscriptions;
    @api subscriptionList;
    viewPage;

    labels = {
        orderSummaryText,
        subTotalText,
        taxesText,
        discountsText,
        totalText,
        continueShoppingText,
        productsText
    }

    get redirectionURL() {
        if(this.orderData?.isPublicCourseExist) {
            return '/category/' + publicCourseCategory;
        }
        return '/' + selfStudyCategoryApi;
    }

    get currencyCode() {
        return this.orderData?.CurrencyIsoCode;
    }

    get showTax() {
        return this.orderData?.TotalTaxAmount != null;
    }

    get taxAmt() {
        return this.orderData?.TotalTaxAmount;
    }

    get showDiscountAmt() {
        return this.orderData?.OrderAdjustment != null;
    }

    get discountAmt() {
        return this.orderData?.OrderAdjustment * -1;
    }

    get productTotalAmt() {
        return this.orderData?.TotalProductAmount;
    }

    get totalAmt() {
        return this.orderData?.GrandTotalAmount;
    }

    handleContinueShopping() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.redirectionURL
            }
        });
    }
}