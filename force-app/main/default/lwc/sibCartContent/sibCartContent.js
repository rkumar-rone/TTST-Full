import { LightningElement, api, track, wire } from 'lwc';
import { createCartItemsLoadAction, dispatchActionAsync } from 'commerce/actionApi';
import { NavigationMixin } from 'lightning/navigation';
import { previewData } from './mockData';
import SIB_Items from '@salesforce/label/c.SIB_Items';
import SIB_showMore from '@salesforce/label/c.SIB_showMore';
import SIB_minQty from '@salesforce/label/c.SIB_minQty';
import SIB_maxQty from '@salesforce/label/c.SIB_maxQty';
import SIB_incrementStep from '@salesforce/label/c.SIB_incrementStep';
import SIB_sku from '@salesforce/label/c.SIB_sku';
import SIB_decrease from '@salesforce/label/c.SIB_decrease';
import SIB_increase from '@salesforce/label/c.SIB_increase';
import SIB_delete from '@salesforce/label/c.SIB_delete';
import SIB_saved from '@salesforce/label/c.SIB_saved';
import SIB_Item from '@salesforce/label/c.SIB_Item';
import SIB_CartName from '@salesforce/label/c.SIB_CartName';
import SIB_EmptyCart from '@salesforce/label/c.SIB_EmptyCart';
import SIB_classCode from '@salesforce/label/c.SIB_classCode';
import SIB_remove from '@salesforce/label/c.SIB_remove';
import SIB_qty from '@salesforce/label/c.SIB_qty';
import SIB_MostPopularName from '@salesforce/label/c.SIB_MostPopularName';
import SIB_CourseName from '@salesforce/label/c.SIB_CourseName';
import SIB_newCourseName from '@salesforce/label/c.SIB_NewCourseName';


const CLEAR_CURRENT_CART_EVT = 'clearcurrentcart';
export default class SibCartContent extends NavigationMixin(LightningElement) {

    labels = {
        showMore: SIB_showMore,
        minQty: SIB_minQty,
        maxQty: SIB_maxQty,
        incrementStep: SIB_incrementStep,
        sku: SIB_sku,
        item: SIB_Item,
        decrease: SIB_decrease,
        increase: SIB_increase,
        delete: SIB_delete,
        saved: SIB_saved,
        items : SIB_Items,
        cartName : SIB_CartName,
        emptyCart : SIB_EmptyCart,
        classCode : SIB_classCode,
        remove : SIB_remove,
        qty : SIB_qty,
        mostPopularName : SIB_MostPopularName,
        courseName : SIB_CourseName,
        newCourseName : SIB_newCourseName
    }

    @api readOnly;
    @api cartItems;
    @api cartDetails;
    @api cartConfig;
    @track cartItemsToShow = [];
    @api isLocked;
    @api isCartStatusCheckout;


    isPreview;

    get sortingOptions() {
        return [
            { label: 'Date Added - Newest First', value: 'CreatedDateDesc', selected: true },
            { label: 'Date Added - Oldest First', value: 'CreatedDateAsc', selected: false },
            { label: 'Name - Z to A', value: 'NameDesc', selected: false },
            { label: 'Name - A to Z', value: 'NameAsc', selected: false }
        ];
    }

    handleSortChange(event) {
        event.preventDefault();
        console.log('sorrrt'+JSON.stringify(this.cartItems));
        let cartItems = [...this.cartItems];
        let sortValue = event.target.value;
        if(sortValue === 'CreatedDateAsc'){
            this.cartItems = cartItems.reverse();
        }
        else if(sortValue === 'NameDesc'){
            this.cartItems = this.sortByName(cartItems).reverse();
        }
        else if(sortValue === 'NameAsc'){
            this.cartItems = this.sortByName(cartItems)
        }
        else{
            this.cartItems = cartItems;
        }
    }

    sortByName(cartItems) {
        cartItems.sort(function (a, b) {
            if (a.name < b.name) {
                return -1;
            }
            if (a.name > b.name) {
                return 1;
            }
            return 0;
        });
        return cartItems;
    }

    get cartHeader() {
        return this.labels.cartName;
    }

    get clearCartText() {
        return this.labels.emptyCart;
    }

    get productCount() {
        if(this.isPreview) {
            return 3;
        }
        if(this.cartConfig.showUniqueCount) {
            return Number(this.cartDetails.uniqueProductCount);
        }else {
            return false;
        }
        return Number(this.cartDetails.totalProductCount);
    }

    get isCartItemsAvailable() {
        if(this.isPreview) {
            this.cartItemsToShow = previewData;
            console.log('cartItemsToShow'+ JSON.stringify(this.cartItemsToShow));
            return;
        }
        console.log('this.cartItems : '+ JSON.stringify(this.cartItems));
        if(this.cartItems != null && this.cartItems.length !== 0) {
            this.requestMoreCartItems();
            this.isLocked = this.cartDetails.isLocked;
            this.isCartStatusCheckout = this.cartDetails.status == 'Checkout' ? true : false;
        }
        return this.cartItems != null;
    }

    async requestMoreCartItems() {
        // increase current pages count
        //pages++;
        // while current items are less than what should be displayed && less than the total items in the cart
        // ==> request more items from the API
        while (this.cartItems.length < this.cartDetails.uniqueProductCount) {
            await dispatchActionAsync(this, createCartItemsLoadAction());
        }
        // show only the necessary items (from 1st item in 1st page to latest in last page)
        //this.cartItemsToShow = this.cartItems.slice(0, this.pages*this.pageSize);
        this.cartItemsToShow = this.cartItems;
        console.log('cartItemsToShow' + JSON.stringify(this.cartItemsToShow));
    }

    connectedCallback() {
    }

    get needsToShowMore() {
        return this.showMoreItemsOption 
            && (this.isPreview || this.cartItemsToShow.length < this.cartDetails.uniqueProductCount) 
            && this.cartConfig.showMoreItemsOption;
    }

    handleShowMoreButton() {
        if (!this.isPreview) {
            this.requestMoreCartItems();
        }
    }

    handleDeleteCartItem(e) {
        e.stopPropagation();
        const cartItemId = e.detail;
        this.cartItemsToShow = this.cartItemsToShow.filter(item => item.id !== cartItemId);
    }

    handleProductNavigation(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + e.detail.id
            }
        });
    }

    handleClearCart() {
        this.dispatchEvent(
            new CustomEvent(CLEAR_CURRENT_CART_EVT, {
                composed: true,
                bubbles: true,
            })
        );
    }
}