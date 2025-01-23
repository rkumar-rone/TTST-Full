import { LightningElement, api, wire } from 'lwc';
import { getFormFactor } from 'experience/clientApi';
import { AppContextAdapter } from 'commerce/contextApi';
import { getSessionContext } from 'commerce/contextApi';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { createSearchFiltersUpdateAction,createSearchSortUpdateAction, dispatchAction } from 'commerce/actionApi';
import getProductListingConfiguration from '@salesforce/apex/SIB_ProductListingPageController.getProductListingConfiguration';
import getProducts from '@salesforce/apex/SIB_ProductListingPageController.getProducts';
import fetchCategoryId from '@salesforce/apex/SIB_ProductListingPageController.getCategoryId';
import noResultsFound from '@salesforce/label/c.SIB_NoResultsFound';
import getConfig from '@salesforce/apex/SIB_ConfiguratorController.getConfiguratorTemplateSettings';
import { consoleLogging } from "c/sibUtils";

export default class SibProductListingPageContainer extends LightningElement {
    static renderMode = 'light';
    labels = {
        noResultsFound
    }
    plpConfig;
    searchResults;
    webstoreId;
    effectiveAccountId;
    customPLP = false;
    scriptLoaded = false;
    pageNumber = 0;
    pageSize;
    refinements;
    sortRuleId;
    isGlobalSearch = false;
    isPaginationClick = false;
    _landingRecordId;
    isLoading = true;

    @wire(getFormFactor)
    formFactor;

    get isDesktop() {
        return this.formFactor === 'Large';
    }

    @api
    productSearchResults;

    @api
    sortRules;

    //garora@rafter.one - 27 Sep 2024 - starts
    categoryId;
    @api
    get searchResultId() {
        return this.categoryId;
    }
    set searchResultId(value) {
        if(value!=null && value!=undefined){
            if((this.categoryId==null || this.categoryId==undefined)){
                this.getCategoryId(value);
            }
        }
    }

    getCategoryId(value){
        fetchCategoryId({'dataMap': {'CategoryName': value }})
        .then((data)=>{
            if(data && data.CategoryId!=null){
                this.categoryId = data.CategoryId;
                this.triggerProductSearch();
            }
        })
        .catch((error)=>{

        })
    }
    //garora@rafter.one - 27 Sep 2024 - ends

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this._landingRecordId = value;

        if (value) {
            this.triggerProductSearch();
        }
    }

    get searchCategoryId() {
        if (this.recordId) {
            return this.recordId;
        } else if(this.term){
            return this.recordId;
        }else {
            return this.categoryId; //garora@rafter.one - 27 Sep 2024
        }
    }

    @api
    get term() {
        return this._term;
    }
    set term(value) {
        this._term = value;
        if (value) {
            this.isPaginationClick = false;
            this.triggerProductSearch();
        }
    }

    /*Gaurang - TATLB-24 - 9 Sep 2024*/
    @api
    showFilters;

    @api 
    showBreadcrumbs;

    questStore;
    connectedCallback() {
        if(window.location.pathname.includes('global-search')){
            this.isGlobalSearch = true;
        }
    }

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
            this.fetchProducts();
        }
    }

    @wire(getProductListingConfiguration,  {mapParams : {} })
    wiredProductConfig({ error, data }) {
        if (data) {
            this.plpConfig = data.plpConfig;
            this.pageSize = this.recordId ? data.plpConfig?.searchResultsPageSize : data.plpConfig?.selfStudyPageSize; //Gaurang Arora - TATLB-34 - 12 Sep 2024
            if(this.pageSize){
                this.triggerProductSearch();
            }
            this.customPLP = data.customPLP;
        } else if (error) {
            consoleLogging('wiredProductConfig: ' + error);
        }
    };

    @wire(getConfig,  { })
    getConfigWired({ error, data }) {
        if (data) {
            this.questStore = data == 'templateTwo' ? true : false;
            // this.isConfigLoaded;
        } else if (error) {
            consoleLogging('getConfigWired: ' + error);
        }
    };

    expressionToSearchResultWrapper() {
        if(this.productSearchResults != null) {
            let searchWrapper = {
                'recordId' : this.productSearchResults.filtersPanel.categories.selectedCategory.id,
                'pageSize' : this.productSearchResults.pageSize,
                'searchResults' : {
                    'filters' : [],
                    'locale' : this.productSearchResults.locale,
                    'pageSize' : this.productSearchResults.pageSize,
                    'products' : [],
                    'searchCategory' : {
                        'children' : [],
                        'id' : this.productSearchResults.filtersPanel.categories.selectedCategory.id,
                        'name' : this.productSearchResults.filtersPanel.categories.selectedCategory.categoryName
                    },
                    'total' : this.productSearchResults.total,
                    'isSuccess' : true
                },
                'isSuccess' : true
            };
            let filters = [];
            let expressionFilters = this.productSearchResults.filtersPanel.facets;
            let i = 0;
            for(i=0; i<expressionFilters.length; i++) {
                let currFacet = expressionFilters[i];
                let currFilter = {
                    'attributeType' : currFacet.attributeType,
                    'displayName' : currFacet.displayName,
                    'displayRank' : currFacet.displayRank,
                    'displayType' : currFacet.displayType,
                    'facetType' : currFacet.facetType,
                    'nameOrId' : currFacet.nameOrId,
                    'values' : []
                };
                let currFacetValues = currFacet.values;
                let j=0;
                for(j=0; j<currFacetValues.length; j++) {
                    let val = {
                        'checked' : currFacetValues[i].checked,
                        'displayName' : currFacetValues[i].id,
                        'nameOrId' : currFacetValues[i].id,
                        'productCount' : currFacetValues[i].productCount,
                        'type' : 'DistinctValue'
                    }
                    currFilter.values.push(val);
                }
                filters.push(currFilter);
            }
            searchWrapper.searchResults.filters = filters;

            let products = [];
            let expressionProducts = this.productSearchResults.cardCollection;
            i = 0;
            for(i=0; i<expressionProducts.length; i++) {
                let currProd = expressionProducts[i];
                let currProduct = {
                    'defaultImage' : {
                        'altText' : currProd.image.alternateText,
                        'url' : currProd.image.url
                    },
                    'name' : currProd.name,
                    'productId' : currProd.id
                };
                
                products.push(currProduct);
            }
            searchWrapper.searchResults.products = products;

            let children = [];
            let expressionCategories = this.productSearchResults.filtersPanel.categories.selectedCategory.items;
            i = 0;
            for(i=0; i<expressionCategories.length; i++) {
                let currCat = expressionCategories[i];
                let currChild = {
                    'id' : currCat.id,
                    'name' : currCat.categoryName
                };
                
                children.push(currChild);
            }
            searchWrapper.searchResults.searchCategory.children = children;

            this.searchResults = searchWrapper;
        }
    }

    get isProductsAvailable() {
        if(this.customPLP) {
            if(this.searchResults != null && this.searchResults?.total > 0) {
                return true;
            }
        } else {
            consoleLogging('this.productSearchResults: ' + JSON.stringify(this.productSearchResults));
            consoleLogging('this.sortRules: ' + JSON.stringify(this.sortRules));

            if(this.productSearchResults != null && this.sortRules != null) {
                this.expressionToSearchResultWrapper();
                consoleLogging('this.searchResults: ' + JSON.stringify(this.searchResults));
                return true;
            }
        }
        return false;
    }

    get isConfigLoaded() {
        return this.plpConfig != null && this.questStore != null;
    }

    get displayProducts() {
        if (this.isProductsAvailable && this.isConfigLoaded && this.scriptLoaded) {
            return true;
        }
        return false;
    }

    fetchProducts() {
        this.isLoading = true;

        if(this.webstoreId && (this.pageNumber || this.pageNumber === 0) && this.pageSize && (this.searchCategoryId || this.term)) {
            let mapParams = {
                webstoreId: this.webstoreId,
                effectiveAccountId: this.effectiveAccountId,
                recordId: this.searchCategoryId,
                term: this.term,
                page: this.pageNumber,
                pageSize: this.pageSize, //21,//this.plpConfig?.pageSize,
                sortRuleId: this.sortRuleId,
                refinements: this.refinements
            };
    
            consoleLogging('fetchProducts mapParams: ' + JSON.stringify(mapParams));
            getProducts({
                'mapParams' : mapParams
            })
            .then((result) => {
                this.isLoading = false;
                consoleLogging('getProducts result: ' + JSON.stringify(result));
                this.searchResults = result.searchResults;
            }).catch((err) => {
                this.isLoading = false;
                consoleLogging('getProducts error: ' + err);
            });
        } else {
            consoleLogging('fetchProducts params: ' + `Params Missing  - webstoreId = ${this.webstoreId}, 
                pageNumber = ${this.pageNumber}, pageSize = ${this.pageSize}, searchCategoryId = ${this.searchCategoryId}, term = ${this.term}`);
        }
    }

    triggerProductSearch() {
        this.fetchProducts();
    }

    handleGotoPageEvent(event) {
        event.stopPropagation();
        this.isPaginationClick = true;
        this.pageNumber = event.detail.pageNumber;
        if(this.customPLP){
            this.triggerProductSearch();
        } else {
            dispatchAction(this, createSearchFiltersUpdateAction({ page: event.detail.pageNumber }));
        }     
    }

    handleFacetValueUpdateEvent(event) {
        event.stopPropagation();
        this.querySelector('c-sib-product-listing-page').handleScrollView();
        const refinements = event.detail.refinements;
        this.refinements = refinements;
        this.pageNumber = 0;
        this.isPaginationClick = false;
        this.triggerProductSearch();
        
    }

    handleCategoryUpdate(event) {
        event.stopPropagation();
        this._recordId = event.detail.categoryId;
        this.pageNumber = 0;
        this.isPaginationClick = false;
        this.searchResults = undefined;
        this.triggerProductSearch();
    }

    handleClearFilters(event) {
        event.stopPropagation();
        this.isPaginationClick = false;
        this._recordId = this._landingRecordId;
        this.refinements = undefined;
        this.searchResults = undefined;
        this.triggerProductSearch();
    }

    handleSearchSortEvent({ detail }) {
        this.sortRuleId = detail.sortRuleId;
        if(this.customPLP) {
            this.triggerProductSearch();
        } else {
            dispatchAction(this, createSearchSortUpdateAction(this.sortRuleId));
        }
       
    }

    constructor() {
        super();
        this.initialLoadCSSAndJS();
    }

    initialLoadCSSAndJS() {
        let themeName = 'product-list';
        let swiperCSSpath = SIBTheme + '/css/swiper-bundle.min.css';
        let mainCSSPath = SIBTheme + '/css/sib-main.css';
        let siteUtilsScriptpath = SIBTheme + '/js/sib-utils.js';
        let swiperScriptpath = SIBTheme + '/js/swiper-bundle.min.js';
        let siteScriptpath = SIBTheme + '/js/sib-site.js';
        Promise.all([
            loadStyle(this, mainCSSPath), loadStyle(this, swiperCSSpath), loadScript(this, siteUtilsScriptpath), loadScript(this, swiperScriptpath)
        ]).then(() => {
            Promise.all([
                loadScript(this, siteScriptpath)
            ]).then(() => {
                this.scriptLoaded = true;
            })
                .catch(error => {
                    consoleLogging('initialLoadCSSAndJS loadScript catch: ' + error);
                });
        })
            .catch(error => {
                consoleLogging('initialLoadCSSAndJS catch: ' + error);
            });
    }

    handleLoadMoreEvent(event) {
        event.stopPropagation();
        this.pageSize = this.pageSize + this.pageSize;
        if(this.customPLP){
            this.triggerProductSearch();
        } else {
            dispatchAction(this, createSearchFiltersUpdateAction({ pageSize: this.pageSize }));
        }  
    }

    get isNoProducts(){
        return !this.searchResults?.total > 0 && !this.isLoading;
    }
}