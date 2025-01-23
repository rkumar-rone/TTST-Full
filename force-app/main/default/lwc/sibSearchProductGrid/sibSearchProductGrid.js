import { api, LightningElement, track, wire } from 'lwc';
import getStorefrontModule from '@salesforce/apex/SIB_ProductListingPageController.getStorefrontModule';

const SHOW_PRODUCT_EVT = 'showproduct';
const ADD_PRODUCT_TO_CART_EVT = 'addproducttocart';
const PAGE_CHANGE_GOTOPAGE_EVT = 'pagegoto';
const ARROW_DOWN = 'ArrowDown';
const ARROW_UP = 'ArrowUp';
const HOME = 'Home';
const END = 'End';

export default class SearchProductGrid extends LightningElement {

    static renderMode = 'light';

    _searchResults;
    
    @api
    plpConfig;

    @api
    resultsLayout;

    @api
    isPaginationClick;

    @track originalData=[];
    @track normalizedDisplayData=[];

    @api
    get searchResults() {
        return this._searchResults;
    }

    set searchResults(value) {
        if(!this.isPaginationClick) {
            this.originalData = [];
            this.normalizedDisplayData = [];
        }

        this._searchResults = value;
        value?.products.forEach((product)=>{
            let index = this.originalData.findIndex((item) => item.productId == product.productId);
            if(!(Number(index)>-1)){
                this.originalData.push(product);
            }
        });

        if(!this.isPaginationClick) {
            this.normalizedDisplayData = this.originalData;
        }
    }

    get isGridLayout() {
        return this.resultsLayout === 'grid';
    }

    get layoutContainerClass() {
        return this.isGridLayout ? 'filter-cards-view grid-view-filter' : 'filter-cards-view list-view-filter';
    }

    handleAddToCart(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(ADD_PRODUCT_TO_CART_EVT, {
                detail: event.detail,
            })
        );
    }

    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(SHOW_PRODUCT_EVT, {
                detail: event.detail,
            })
        );
    }

    handleKeyDown(event) {
        const { code } = event;
        if (event.target instanceof HTMLElement) {
            const id = event.target.dataset.id;
            const index = this.normalizedDisplayData.findIndex((product) => product.productId === id);
            const callToActionButtonEnabled = this.plpConfig?.showCallToActionButton;
            switch (code) {
                case ARROW_DOWN:
                    if (!callToActionButtonEnabled) {
                        event.preventDefault();
                        this.focusListItem(index, +1);
                    }
                    break;
                case ARROW_UP:
                    if (!callToActionButtonEnabled) {
                        event.preventDefault();
                        this.focusListItem(index, -1);
                    }
                    break;
                case HOME:
                    event.preventDefault();
                    this.focusListItem(0, 0);
                    break;
                case END:
                    event.preventDefault();
                    this.focusListItem(0, -1);
                    break;
                default:
                    break;
            }
        }
    }

    focusListItem(baseIndex, steps) {
        const itemCount = this.normalizedDisplayData.length;
        let newActiveIndex = (baseIndex + steps) % itemCount;

        if (newActiveIndex < 0) {
            newActiveIndex = itemCount - 1;
        }
        Array.from(this.querySelectorAll('c-sib-search-product-card')).at(newActiveIndex)?.focus();
    }
    
    handleGotoPageEvent(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(PAGE_CHANGE_GOTOPAGE_EVT, {
                detail: event.detail
            })
        );
    }

    handlePagination(event){
        event.stopPropagation();
        if(event.detail.value){
            this.normalizedDisplayData = this.originalData.slice(0,event.detail.value);
        }
    }
}