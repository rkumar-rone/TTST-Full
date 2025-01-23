import { LightningElement, api, track } from 'lwc';
import { previous, next, resultsLimitHitText } from './labels';
const PAGE_CHANGE_GOTOPAGE_EVT = 'pagegoto';
const PAGINATION_EVT = 'paginationchange'

export default class SearchPagingControl extends LightningElement {

    static renderMode = 'light';

    label = {
        previous,
        next,
        resultsLimitHitText,
    };

    @api
    isPaginationClick;

    @api
    plpConfig;

    currentPageNumber = 0;

    totalRecords;
    displayDataLength;
    displayData;
    categoryName;
    showMoreButton = false;
    disableButton = false;
    moreRecords;
    recordLimit=0;
    stencilLoading=false;
    @track actualRecords=[];

    @track _searchResults;

    @api
    get searchResults() {
        return this._searchResults;
    }

    set searchResults(value) {
        this._searchResults = value;
        let tempRecs=[];

        if(!this.isPaginationClick) {
            this.actualRecords = [];
            this.recordLimit = 0;
        }

        value?.products.forEach((product)=>{
            let index = this.actualRecords.findIndex((item) => item.productId == product.productId);
            if(!(Number(index)>-1)){
                tempRecs.push(product);
                this.actualRecords.push(product);
            }
        });
        if(tempRecs.length>0){
            this.handleReceivedValueChange(value);
        }
    }

    handleReceivedValueChange(newValue) {
        this.totalRecords = newValue?.total;
        this.displayDataLength = newValue?.products.length;
        this.displayData = newValue?.products;
        this.categoryName = newValue?.searchCategory.name;
        this.invokePagination();
    }

    get buttonLabel(){
        return (this.categoryName && this.categoryName.toLowerCase().includes('course'))? 'See more '+this.categoryName+' (+'+this.moreRecords+')' : 'See more '+this.categoryName+' Courses (+'+this.moreRecords+')';
    }

    invokePagination(){
        this.recordLimit+=this.displayDataLength;
        if(this.totalRecords>=this.recordLimit){
            this.showMoreButton = true;
            this.moreRecords = Number(this.totalRecords) - Number(this.recordLimit);
            if(this.totalRecords==this.recordLimit){
                this.showMoreButton = false;
            }
            this.dispatchEventToParent();
            this.disableButton = false;
            this.stencilLoading = false;
        }
        else{
            this.showMoreButton = false;
            this.stencilLoading = false;
        }
    }

    dispatchEventToParent(){
        this.dispatchEvent(
            new CustomEvent(PAGINATION_EVT, {
                detail: {
                    value: this.recordLimit,
                },
            })
        );
    }



    handleMoreRecords(){
        this.stencilLoading = true;
        this.showMoreButton = false;
        this.currentPageNumber++;
        this.fireEvent(this.currentPageNumber);
    }

    fireEvent(pageNumber){
        this.disableButton = true;
        this.dispatchEvent(
            new CustomEvent(PAGE_CHANGE_GOTOPAGE_EVT, {
                detail: {
                    pageNumber: pageNumber,
                },
            })
        );
    }
}