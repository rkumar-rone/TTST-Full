import { api, LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import communityId from '@salesforce/community/Id';
import getCartSummary from '@salesforce/apex/Saltbox_B2BCartController2.getCartSummary';
import calculatePromotions from '@salesforce/apex/Saltbox_B2BCartController2.calculatePromotions';


import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';

import { subscribe, MessageContext } from 'lightning/messageService';
import cartChanged from '@salesforce/messageChannel/lightning__commerce_cartChanged';

const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

export default class SaltboxCartSummary extends LightningElement {
    /**
     * An event fired when the cart items change.
     * This event is a short term resolution to update any sibling component that may want to update their state based
     * on updates in the cart items.
     *
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     *
     * @event CartContents#cartitemsupdated
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * The pricing information for the cart summary's total.
     *
     * @typedef {Object} Prices
     *
     * @property {String} [originalPrice]
     *  The  list price aka "strikethrough" price (i.e. MSRP) of the cart.
     *  If the value is null, undefined, or empty, the list price will not be displayed.
     *
     * @property {String} finalPrice
     *   The final price of the cart.
     * 
     * @property {String} subtotalPrice
     *   The subtotal of the cart before discount & taxes
     * 
     * @property {String} promoAmount
     *   The amount of any promo adjustments applied to the cart
     *   
     */

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;


    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     * We want to start listening for the 'cartitemsupdated'
     *
     * NOTE:
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     */
    connectedCallback() {
        console.log('in connectedCallback');
        this.subscribeToMessageChannel();
        registerListener(
            CART_ITEMS_UPDATED_EVT,
            this.getUpdatedCartSummary,
            this
        );
        // Initialize 'cartsummary' as soon as the component is inserted in the DOM  by
        // calling getCartSummary imperatively.
        this.getUpdatedCartSummary();
        //this.getQuote();
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    /**
     * Used to listen to cart changes and update the cart items
     */
    subscription = null;

    @wire(MessageContext)
    messageContext;
    
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                cartChanged,
                () => this.getUpdatedCartSummary()
            );
        }
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            cartSummaryHeader: 'Cart Total',
            subtotal: 'Subtotal',//set back to Subtotal after prop fix
            promo: 'Promotions',
            total: 'Total',
            tax: 'Tax'
        };
    }


    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    /**
     * The pricing information to be displayed in the summary
     * @type {Prices}
     */
    get prices() {
        return {
            originalPrice: this.cartSummary && this.cartSummary.totalListPrice,
            promoAmount: this.cartSummary && this.cartSummary.totalPromotionalAdjustmentAmount,
            subtotalPrice: this.cartSummary && this.cartSummary.totalProductAmount,
            finalPrice: this.cartSummary && this.cartSummary.totalProductAmountAfterAdjustments,
            taxes: this.cartSummary?.totalTaxAmount,
            finalPriceWithTaxes: Number(this.cartSummary?.totalProductAmountAfterAdjustments) + Number(this.cartSummary?.totalTaxAmount)
        };
    }

    get showPromotions(){
        return Number(this.prices.promoAmount) !== 0;
    }
    get showTaxes(){
        return Number(this.prices.taxes) !== 0;
    }

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {String}
     */
    get currencyCode() {
        return (this.cartSummary && this.cartSummary.currencyIsoCode) || 'USD';
    }

    /**
     * Representation for Cart Summary
     *
     * @type {object}
     * @readonly
     * @private
     */
    cartSummary;

    /**
     * Get cart summary from the server via imperative apex call
     */
    async getUpdatedCartSummary() {
        try {
            // Ensure the calculatePromotions is called and completed before fetching the cart summary
            //await calculatePromotions({ cartId: this.recordId });
            
            // Once the promotions are calculated, fetch the updated cart summary
            const cartSummary = await getCartSummary({
                communityId: communityId,
                activeCartOrId: this.recordId,
                effectiveAccountId: this.resolvedEffectiveAccountId
            });
    
            // Update the cart summary state
            this.cartSummary = cartSummary;
    
        } catch (error) {
            // Handle any errors that occur during the process
            console.error('Error fetching cart summary or calculating promotions:', error);
    
            // Optionally, show a toast to the user indicating the error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'There was an issue loading your cart summary.',
                    variant: 'error',
                }),
            );
        }
    }


    /**
     * Should the original price be shown
     * @returns {boolean} true, if we want to show the original (strikethrough) price
     * @private
     */
    get showOriginal() {
        return displayOriginalPrice(
            true,
            true,
            this.prices.subtotalPrice,
            this.prices.originalPrice
        );
    }

    /**
     * Gets the dynamically generated aria label for the original price element
     * @returns {string} aria label for original price
     * @private
     */
    get ariaLabelForOriginalPrice() {
        return getLabelForOriginalPrice(
            this.currencyCode,
            this.prices.originalPrice
        );
    }

}