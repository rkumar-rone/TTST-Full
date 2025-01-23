import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { createCartItemAddAction, createSearchFiltersClearAction, createSearchFiltersUpdateAction,createSearchSortUpdateAction, dispatchAction } from 'commerce/actionApi';
import SearchFiltersModal from 'c/sibSearchFiltersModal';
import basePath from '@salesforce/community/basePath';
import { navigate, NavigationContext, NavigationMixin } from 'lightning/navigation';
import CommonModal from 'c/sibCommonModal';
import modalLabel from '@salesforce/label/c.Commerce_Search_Facets_modalLabel';
import actionViewCart from '@salesforce/label/c.Product_ModalAddToCart_actionViewCart';
import actionContinueShopping from '@salesforce/label/c.Product_ModalAddToCart_actionContinueShopping';
import messageSuccessfullyAddedToCart from '@salesforce/label/c.Product_ModalAddToCart_messageSuccessfullyAddedToCart';
import clearAllLabel from '@salesforce/label/c.Search_Facets_clearButton';
import searchResults from '@salesforce/label/c.SIB_SearchResults';

const DEFAULT_SEARCH_FILTER_PAGE = 1;
const PAGE_CHANGE_GOTOPAGE_EVT = 'pagegoto';
const EVENT_SORT_ORDER_CHANGED = 'searchsort';

export default class SibProductListingPage extends NavigationMixin(LightningElement)  {

    static renderMode = 'light';

    _searchResults;

    labels = {
        modalLabel,
        actionViewCart,
        actionContinueShopping,
        messageSuccessfullyAddedToCart,
        clearAllLabel,
        searchResults
    };

    @api
    plpConfig;

    @api
    get searchResults() {
        return this._searchResults;
    }
    set searchResults(value) {
        if(value) {
            this._searchResults = JSON.parse(JSON.stringify(value));

            // Function to sort 'Month / Year' values in the filters array
            this._searchResults.filters.forEach(filter => {
                if (filter.nameOrId === "Month_Year__c") {
                    filter.values.sort((a, b) => new Date(a.displayName) - new Date(b.displayName));
                }
            });
        }
    }

    //Gaurang Arora - TATLB-24 - 10 Sep 2024
    @api
    showFilters;

    @api
    showBreadcrumbs;
    //-----------------------

    @track
    resultsLayout;

    @api
    isPaginationClick;

    @api isGlobalSearch;

    isClearAllClick = false;

    get categoryPath() {
        let pathList = [{ url: basePath + '/', name: 'Home', id: 'home', isLast: false }];
        if(!this.isGlobalSearch) {
            let url = this.searchResults?.searchCategory?.urlSlug ? this.searchResults?.searchCategory?.urlSlug : this.searchResults?.searchCategory?.id;
            pathList.push({ 
                url: basePath + '/category/' + url,
                name: this.searchResults?.searchCategory?.name, 
                id: this.searchResults?.searchCategory?.id,
                isLast: true
            });
        }
    
        return pathList;
    }

    get sortRules() {
        return this.searchResults?.sortRules;
    }

    setLayoutAsList() {
        this.resultsLayout = 'list';
        setTimeout(() => {
            const buttonsView = document.querySelector(".btns-view");
            if (buttonsView) {
                let gridViewButton = buttonsView.querySelector(".grid-view-button");
                gridViewButton.classList.remove("active");
                let listViewButton = buttonsView.querySelector(".list-view-button");
                listViewButton.classList.add("active");
            } else {
                console.error("buttonsView element not found.");
            }
        }, 1);
    }

    setLayoutAsGrid(event){
        this.resultsLayout = 'grid';
        setTimeout(() => {
            const buttonsView = document.querySelector(".btns-view");
            if (buttonsView) {
                let gridViewButton = buttonsView.querySelector(".grid-view-button");
                gridViewButton.classList.add("active");
                let listViewButton = buttonsView.querySelector(".list-view-button");
                listViewButton.classList.remove("active");
            } else {
                console.error("buttonsView element not found.");
            }
        }, 1);
        
        
    }

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(NavigationContext)
    navContext; 

    
    get isGridLayoutEnabled() {
        return this.plpConfig?.availableLayouts?.includes('grid');
    }

    get isListLayoutEnabled() {
        return this.plpConfig?.availableLayouts?.includes('list');
    }

    get showLayoutButtons(){
        return this.plpConfig?.showLayoutButtons;
    }
    handleCategoryUpdateEvent(event) {
        event.stopPropagation();
        this.isClearAllClick = true;
        const categoryId = event.detail;
        this.dispatchEvent(
            new CustomEvent('categoryupdate', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    categoryId : categoryId
                },
            })
        );

        // const searchFiltersPayload = {
        //     page: DEFAULT_SEARCH_FILTER_PAGE, // Go back to the first page
        //     categoryId: categoryId,
        // };

        // dispatchAction(this, createSearchFiltersUpdateAction(searchFiltersPayload));
    }

    handleFacetValueUpdateEvent(event) {
        event.stopPropagation();
        this.isClearAllClick = false;
        //const { mruFacet, refinements } = event.detail;
        const refinements = event.detail.refinements;
        this.dispatchEvent(
            new CustomEvent('facetvalueupdate', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    refinements : refinements
                },
            })
        );
        // const searchFiltersPayload = {
        //     page: DEFAULT_SEARCH_FILTER_PAGE, // Go back to the first page
        //     refinements,
        //     mruFacet,
        // };

        // dispatchAction(this, createSearchFiltersUpdateAction(searchFiltersPayload));
    }

    handleClearAllFiltersEvent(event) {
        event.stopPropagation();
        this.isClearAllClick = true;
        //dispatchAction(this, createSearchFiltersClearAction());
        this.dispatchEvent(
            new CustomEvent('clearfilters', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    refinements : []
                },
            })
        );
    }

    handleOpenFiltersModal(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        SearchFiltersModal.open({
            label: this.labels.modalLabel,
            onfacetvalueupdate: (event) => this.handleFacetValueUpdateEvent(event),
            onclearallfilters: (event) => this.handleClearAllFiltersEvent(event),
            oncategoryupdate: (event) => this.handleCategoryUpdateEvent(event),
            displayData: this.searchResults,
            pageRef: this.currentPageReference,
        });
    }
   
    handleAddToCart(event) {
        event.stopPropagation();
        const { productId, quantity } = event.detail;
        dispatchAction(this, createCartItemAddAction(productId, quantity), {
            onSuccess: () => {
                CommonModal.open({
                    label: this.labels.messageSuccessfullyAddedToCart,
                    size: 'small',
                    secondaryActionLabel: this.labels.actionContinueShopping,
                    primaryActionLabel: this.labels.actionViewCart,
                    onprimaryactionclick: () => this.navigateToCart(),
                });
            },
        });
    }
    
    navigateToCart() {
        this.navContext &&
            navigate(this.navContext, {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart',
                },
            });
    }
    
    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + event.detail.productId
            }
        });
    }

    handleSearchSortEvent({ detail }) {
        //dispatchAction(this, createSearchSortUpdateAction(detail.sortRuleId));
        this.dispatchEvent(
            new CustomEvent(EVENT_SORT_ORDER_CHANGED, {
                bubbles: true,
                cancelable: true,
                composed: true,
                detail: {
                    sortRuleId: detail.sortRuleId,
                },
            })
        );
    }

    connectedCallback() {   
        this.resultsLayout = this.plpConfig?.defaultView;
        console.log('this.resultsLayout:'+this.resultsLayout);

        if(this.resultsLayout==='list'){
            this.setLayoutAsList();
        }else{
            this.setLayoutAsGrid();
        }
    }

    handleGotoPageEvent(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(PAGE_CHANGE_GOTOPAGE_EVT, {
                detail: event.detail,
                composed:true,
                bubbles:true
            })
        );
    }

    @api 
    handleScrollView(){
        let containerChoosen = this.querySelector('.filter-content');
        let containerPosition = containerChoosen.getBoundingClientRect().top + window.scrollY;
        window.scrollTo({
            top: containerPosition - 205,  
            behavior: 'smooth'
        });
    }
}