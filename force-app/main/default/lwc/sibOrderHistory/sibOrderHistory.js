import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { startReOrder } from 'commerce/orderApi';
import { navigate, NavigationContext } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { OrdersAdapter } from 'commerce/orderApi';
import CommonModal from 'c/sibCommonModal';
import MAIN_TEMPLATE from "./sibOrderHistory.html";
import STENCIL from "./sibOrderHistoryStencil.html";


export default class SibOrderHistory extends NavigationMixin(LightningElement) {
    static renderMode = 'light';
    isStencilLoading = true;
    showOrders = false;
    noOrdersFound = false;
    @track orderList = [];
    @track allOrders = [];
    totalCount = 0;
    @api pageSize = 25;
    _pageNumber = 1;
    defaultSortBy = 'DESC';
    orderSummaryList = [];
    showApplyButton = true;
    originalOrders = [];
    pageToken;
    nextPageToken;
    previousPageToken;
    showNext = false;
    showPrevious = false;
    startDateISOTemp;
    endDateISOTemp;
    startDateISO;
    endDateISO;
    startDateValue;
    endDateValue;

    @wire(NavigationContext)
    navContext;

    @wire(OrdersAdapter,{"pageToken":'$pageToken',"pageSize":'$pageSize' ,"earliestDate" :'$startDateISO',"latestDate" :'$endDateISO',"ownerScoped" :'false',"fields" : ["Id","OrderedDate","Status","GrandTotalAmount","OrderNumber"]})
    getOrderSummary({ data, error}){
        if(data){
            let orderSumm = data.orderSummaries;
            if(data.nextPageToken){
                this.showNext = true;
                this.nextPageToken = data.nextPageToken ;
            }else{
                this.showNext = false;
            }
            if(data.previousPageToken) {
                this.showPrevious = true;
                this.previousPageToken = data.previousPageToken ;
            }else{
                this.showPrevious = false;
            }
            this.originalOrders = orderSumm;
            this.processOrders();
        }
        else if(error){
            console.log('error-' + JSON.stringify(error));
        }
        let t = this;
        this.isStencilLoading = true;
        setTimeout(() => {
            t.isStencilLoading = false;
        }, 1000);
    }

    showNextPage(){
        if (this.showNext) {
            this.pageToken = this.nextPageToken;
            this._pageNumber += 1;
        }
    }

    showPreviousPage(){
        if (this.showPrevious) {
        this.pageToken = this.previousPageToken;
        this._pageNumber -= 1;
        }
    }


    //Filter Dates
    endDate = new Date().toJSON().slice(0,10);
    startDate = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toJSON().slice(0,10);

    processOrders() {
        let endOfDay = new Date(this.endDate);
        endOfDay.setDate(endOfDay.getDate() + 1);
        let updatedEndDate = endOfDay.toJSON().slice(0, 10);
        this.allOrders = this.originalOrders.filter(ele => ele.orderedDate >= this.startDate && ele.orderedDate <= updatedEndDate);
        if (this.defaultSortBy === 'DESC') {
            this.allOrders = this.allOrders.sort((a,b) => new Date(b.orderedDate) - new Date(a.orderedDate));
        } else {
            this.allOrders = this.allOrders.sort((a,b) => new Date(a.orderedDate) - new Date(b.orderedDate));
        }
        this.showUpdatedOrders();

    }

    showUpdatedOrders(){
        this.totalCount = this.allOrders.length;
        this.showOrders = this.totalCount > 0;
        this.noOrdersFound = this.totalCount === 0;
        this.orderList = this.allOrders.slice(0,this.pageSize);
    }
    get sortByOptions() {
        return [
            { label: 'Most Recent Order', value: 'DESC' },
            { label: 'Oldest Order', value: 'ASC' }
        ];
    }

    handleStartDate(evt) {
        this.startDate = evt.target.value;
        this.startDate = this.startDate.slice(0,10);
        this.startDateValue = this.startDate;
        this.startDateISOTemp = this.startDate + 'T00:00:00.000-0000';
        if(this.startDate > this.endDate) {
            this.template.querySelector('c-sib-show-toast-message').showToast('Start Date cannot be greater than End Date.','error');
            this.showApplyButton = false;
        }
        else{
            this.showApplyButton = true;
        }
    }

    handleEndDate(evt) {
        this.endDate = evt.target.value;
        this.endDate = this.endDate.slice(0,10);
        this.endDateValue = this.endDate;
        this.endDateISOTemp = this.endDate + 'T00:00:00.000-0000';
        if(this.startDate > this.endDate) {
            this.template.querySelector('c-sib-show-toast-message').showToast('Start Date cannot be greater than End Date.','error');
            this.showApplyButton = false;
        }
        else{
            this.showApplyButton = true;
        }
    }

    handleSortChange(evt) {
        this.defaultSortBy = evt.target.value;
        this._pageNumber = 1;
        this.processOrders();
    }

    handleApplyFilter() {
        this._pageNumber = 1;
        this.startDateISO = this.startDateISOTemp;
        this.endDateISO = this.endDateISOTemp;
        this.pageToken = '';
    }

    handleResetFilter() {
        this.endDate = new Date().toJSON().slice(0,10);
        this.startDate = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toJSON().slice(0,10);
        this.startDateISO = new Date(new Date().setFullYear(new Date().getFullYear() - 1)).toJSON().slice(0,10) + 'T00:00:00.000-0000';
        let endOfDay = new Date();
        endOfDay.setDate(endOfDay.getDate() + 1);
        this.endDateISO = endOfDay.toJSON().slice(0,10) + 'T00:00:00.000-0000';
        this.pageToken = '';
        this.showApplyButton = true;
        this._pageNumber = 1;
        this.startDateValue = '';
        this.endDateValue = '';
    }

    handleViewDetails(event) {
        const orderId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: basePath + '/OrderSummary/' + orderId
            }
        }).then((url) => {
            window.open(url,'_self');
        });
    }

    async handleOnReorder(event)
    {
        this.isStencilLoading = true;
        const orderId = event.target.dataset.id;
        const result = await startReOrder({orderSummaryId: orderId , cartStateOrId : 'current'});
        console.log(result);
        if(result && result.cartId)
        {
            this.isStencilLoading = false;
            CommonModal.open({
                label: 'All items were added to cart',
                size: 'small',
                secondaryActionLabel: 'CONTINUE SHOPPING',
                primaryActionLabel: 'VIEW CART',
                onprimaryactionclick: () => this.navigateToCart(),
            });
        }
    }

    /**
     * Navigates to the cart page when the primary button is clicked
     * from the modal after adding an item to the cart
     * @private
     */
    navigateToCart() {
        this.navContext &&
            navigate(this.navContext, {
                type: 'comm__namedPage',
                attributes: {
                    name: 'Current_Cart',
                },
            });
    }

    render() {
        if(this.isStencilLoading){
            //loading screen
            return STENCIL;
        }else{
            //main screen
            return MAIN_TEMPLATE;
        }
    }
}