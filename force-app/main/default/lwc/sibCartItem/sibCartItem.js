import { LightningElement, api,wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { CartItemsAdapter} from "commerce/cartApi";

const DELETE_ITEM_EVENT = 'deletecartitem';
const NAVIGATE_PRODUCT_EVENT = 'navigatetoproduct';
const QUANTITY_CHANGED_EVT = 'quantitychanged';
/**
 * UI component for an individual cart item. Handles deletion,
 * quantity update, product navigation and fields to display per item.
 */
export default class SibCartItem extends LightningElement {

    productImage = SIBTheme + '/images/Course-Default-Image.png';

    /**
     * @description UI labels, to be replaced by Custom Labels and their translations
     */
    @api labels;

    /**
     * @description Current Cart Item
     */
    @api item;

    /**
     * @description List of fields (Api Names) to display for each Item
     */
    get productFields() {
        return this.cartConfig?.productFields;
    }
    get productFields() {
        return this.cartConfig?.productFields;
    }

    /**
     * @description Preview mode if component is rendered in the Builder
     */
    @api isPreview;

    @api cartConfig;
    @api readOnly;
    @api isLocked;
    @api isCartStatusCheckout;

    /**
     * @description Minimum quantity from purchaseQuantityRule if provided
     */
    minQuantity;

    /**
     * @description Maximum quantity from purchaseQuantityRule if provided
     */
    maxQuantity;

    /**
     * @description Increment step from purchaseQuantityRule if provided
     */
    incrementStep;

    get imgAltText() {
        return this.item?.productDetail?.defaultImage?.altText;
    }

    get imgUrl() {
        if(this.item?.productDetail?.defaultImage?.url?.includes('default-product-image')) {
            return this.productImage;
        } else {
            if(this.item?.productDetail?.defaultImage?.url?.includes("cms")) {
                return basePath + '/sfsites/c/'+ this.item.productDetail.defaultImage.url;
            }
            return this.item?.productDetail?.defaultImage?.url;
        }
    }

    get productName() {
        return this.item?.productDetail?.name;
    }

    get productSku() {
        return this.item?.productDetail?.productSku;
    }

    get courseType() {
        if(this.item?.productDetail?.isCourse){
            return this.labels.courseName;
        }
        return this.item?.productDetail?.productGroup;
    }
    
    get mostPopularTag(){
        return this.item?.productDetail?.isMostPopular ? true : false
    }

    get newCourseTag() { 
        return this.item?.productDetail?.isNewCourse ? true : false
    }

    get productImageBgColorClass(){
        return this.item?.productDetail?.isCourse ? ' item-card__img blue-bg' : 'item-card__img green-bg'
    }
    get shortDescription() {
        return this.item?.productDetail?.fieldsMap['Short_Description__c'];
    }

    get ItemDiscountAmount(){
        return this.item?.totalDiscount;
    }

    get showActualPrice() {
        return this.cartConfig?.showActualPrice &&  this.productPrice < this.calculatedTotalUnitPrice ;
    }

    get calculatedTotalUnitPrice(){
        return this.item?.unitPrice * this.item?.quantity;
    }
    
    get productSalesPrice() {
        return this.item?.unitPrice;
    }

    get productPrice() {
        return this.item?.totalPrice;
    }

    get productListPrice() {
        return this.item?.listPrice;
    }

    get showRemoveItemOption() {
        return this.cartConfig?.showRemoveItemOption && !this.isLocked;
    }

    get showLineItemTotal() {
        return this.cartConfig?.showLineItemTotal;
    }

    get showSKU() {
        return this.cartConfig?.showSKU;
    }

    get showProductImage() {
        return this.cartConfig?.showProductImage;
    }

    get showPricePerUnit() {
        return this.cartConfig?.showPricePerUnit;
    }

    get hideQuantitySelector() {
        return this.cartConfig?.hideQuantitySelector && !this.isLocked;
    }

    connectedCallback() {
        // minQuantity falls back to 1 if purchaseQuantityRule is not provided
        this.minQuantity = Number(this.item.productDetail.purchaseQuantityRule?.minimum || 1);
        // ommit maxQuantity if purchaseQuantityRule is not provided
        this.maxQuantity = Number(this.item.productDetail.purchaseQuantityRule?.maximum) || undefined;
        // incrementStep falls back to 1 if purchaseQuantityRule is not provided
        this.incrementStep = Number(this.item.productDetail.purchaseQuantityRule?.increment || 1);
    }

    renderedCallback() {
        // report invalid quantities after rendering the item
        this.refs.quantitySelector?.reportValidity();
    }

    /**
     * @description Returns current cart item currency code
     * @returns {String}
     */
    get currencyCode() {
        return this.item?.currencyIsoCode;
    }

    /**
     * @description Fixes the promotion badge under the quantity selector
     * @returns {String}
     */
    get additionalBadgeStyle() {
        // return !this.hideQuantitySelector ? 'top: -20px' : 'top: 10px';
        return 'top: -20px';
    }

    /**
     * @description Returns current item quantity
     * @returns {Number}
     */
    get quantity() {
        return Number(this.item?.quantity);
    }
    
    /**
     * @description Returns if a quantity rule exists for the current item,
     * an existent one should have the required field maxQuantity
     * @returns {Boolean}
     */
    get hasQuantityRule() {
        return this.maxQuantity;
    }

    /**
     * @description Returns help text which describes the quantity rule
     * @returns {String}
     */
    get quantityRuleHelpText() {
        return `${this.labels.minQty}: ${this.minQuantity}, ${this.labels.maxQty}: ${this.maxQuantity}, ${this.labels.incrementStep}: ${this.incrementStep}`;
    }

    /**
     * @description Returns true if minQuantity is reached or the closest possible value to it
     * @returns {Boolean}
     */
    get stopDecreaseQuantity() {
        return this.item.quantity === this.minQuantity || this.item.quantity-this.incrementStep<this.minQuantity || this.isCartStatusCheckout;
    }

    /**
     * @description Returns true if maxQuantity is reached or the closest possible value to it
     * @returns {Boolean}
     */
    get stopIncreaseQuantity() {
        return this.item.quantity === this.maxQuantity || this.item.quantity+this.incrementStep>this.maxQuantity || this.isCartStatusCheckout;
    }

    /**
     * @description Returns saved amount (adjustment amount)
     * @returns {Number | undefined}
     */
    get savedAmount() {
        // if (this.showPromotions && this.item.adjustmentAmount !== 0) {
        //     return this.item.adjustmentAmount*-1;
        // }
        if(this.productPrice && this.productListPrice && this.productPrice !== 0 && this.productListPrice !== 0 && this.cartConfig?.showSavedAmount && (this.productListPrice - this.productPrice) > 0) {
            return this.productListPrice - this.productPrice;
        }
        return undefined;
    }

    /**
     * @description Returns whether or not to display original item price
     * @returns {Boolean}
     */
    get needsOriginalPrice() {
        // return this.showOriginalPrice && this.item.listPrice !== 0;
        return this.item?.listPrice !== 0 && this.item?.listPrice != this.item?.totalPrice && this.item?.listPrice > this.item?.totalPrice && this.cartConfig?.showOriginalPrice;
    }

    /**
     * @description Shows current items based on configuration:
     * 1 - Extract fields from productFields property
     * 2 - Set label + value (switch from camelCase to sentence case)
     * 3 - Sort items by the order in productFields property
     * 
     * @returns {List}
     */
    get fieldsWithLabels() {

        let fieldList = [];
        let tempFieldMap = {};
        for (let keys in this.item?.productDetail?.fieldsMap) {
            tempFieldMap[keys.toLowerCase()] = this.item?.productDetail?.fieldsMap[keys];
        }
        //TO:DO
        this.productFields.forEach(element => {
            
            let field = {
                showLabel: element.showLabel,
                label: element.label,
                value: tempFieldMap[element.name],
                hasValue: tempFieldMap[element.name] ? true : false
            }
            fieldList.push(field);
        });

        return fieldList;
        
    }

    /**
     * @description Decreases the quantity by the value in incrementStep
     * @param {CustomEvent} e
     */
    decreaseQty(e) {
        e.stopPropagation();
        if (!this.isPreview && this.refs.quantitySelector.validity.valid) {
            const newQty = this.quantity - this.incrementStep;
            this._updateQty(newQty);
        }
    }

    /**
     * @description Increases the quantity by the value in incrementStep
     * @param {CustomEvent} e
     */
    increaseQty(e) {
        e.stopPropagation();
        if (!this.isPreview && this.refs.quantitySelector.validity.valid) {
            const newQty = this.quantity + this.incrementStep;
            this._updateQty(newQty);
        }
    }

    /**
     * @description Updates the quantity by the new value in the quantity input
     * @param {CustomEvent} e
     */
    handleQtyChange(e) {
        e.stopPropagation();
        if (!this.isPreview && this.refs.quantitySelector.validity.valid) {
            const newQty = Number(this.refs.quantitySelector.value);
            this._updateQty(newQty);
        }
    }

    /**
     * @description Updates the quantity by the new value in parameter
     * @param {Number} newQty
     * @private
     */
    _updateQty(newQty) {
        const cartItemId = this.item.itemId;
        const productId = this.item?.productId;
        this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                detail: {
                    cartItemId,
                    newQty,
                    productId
                },
                composed: true,
                bubbles: true,
            })
        );
        let updatedCartItem = {cartItem: cartItemId};
        //updatedCartItem.cartItem.productDetails.fields = this.item.productDetail.fields;
        //this.item = [updatedCartItem].map(this.mapCartItem)[0];
    }

    /**
     * @description Sends an event to the parent component to delete the current item
     * @param {CustomEvent} e
     */
    handleDelete(e) {
        e.stopPropagation();
        if (!this.isPreview) {
            this.dispatchEvent(
                new CustomEvent(DELETE_ITEM_EVENT, {
                    detail: this.item.itemId,
                    composed: true,
                    bubbles: true,
                })
            );
        }
    }

    /**
     * @description Sends an event to the parent component to navigate to the current item
     * @param {CustomEvent} e
     */
    handleProductRedirection(e){
        e.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(NAVIGATE_PRODUCT_EVENT, {
                detail: {
                    id: this.item?.productId,
                    name: this.item?.productDetail?.name
                },
                composed: true,
                bubbles: true,
            })
        );
    }

    // Cart item mapping function
    mapCartItem = (sourceCartItem) => {
        const {
            cartItem: {
                cartItemId: id,
                name,
                quantity,
                type,
                itemizedAdjustmentAmount,
                salesPrice,
                totalAdjustmentAmount: adjustmentAmount,
                totalAmount: totalAmount,
                totalListPrice: listPrice,
                totalPrice: price,
                totalTax: tax,
                unitAdjustedPrice,
                unitAdjustmentAmount,
                productDetails,
            },
            messages
        } = sourceCartItem;

        return {
            id,
            name,
            quantity,
            type,
            itemizedAdjustmentAmount,
            salesPrice,
            adjustmentAmount,
            totalAmount,
            listPrice,
            price,
            tax,
            unitAdjustedPrice,
            unitAdjustmentAmount,
            ProductDetails: {
                name: productDetails.fields.Name,
                productId: productDetails.productId,
                purchaseQuantityRule: productDetails.purchaseQuantityRule,
                sku: productDetails.sku,
                fields: productDetails.fields,
                thumbnailImage: productDetails.thumbnailImage,
                variationAttributes: productDetails.variationAttributes,
            },
            Messages: messages,
        };
    };

    @wire(CartItemsAdapter)
    setCartSummary({ data, error }) {
        if (data) {
            console.log("Cart Summary:", JSON.stringify(data));
        } else if (error) {
            console.log(JSON.stringify(error));
        }
}
}