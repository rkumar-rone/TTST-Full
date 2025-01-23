import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationContext, NavigationMixin } from 'lightning/navigation';
import { getFormFactor } from 'experience/clientApi';
import FiltersModal from 'c/sibPublicCourseCalendarFiltersModal';
import getPicklists from '@salesforce/apex/CourseManagementController.getPicklists';
import getAllCourses from '@salesforce/apex/CourseManagementController.getAllCourses';
import getProductListingConfiguration from '@salesforce/apex/SIB_ProductListingPageController.getProductListingConfiguration';
import { label } from './labels';

export default class SibPublicCourseCalendarContainer extends NavigationMixin(LightningElement) {

    static renderMode = 'light';

    @wire(getFormFactor)
    formFactor;

    get isDesktop() {
        return this.formFactor === 'Large';
    }

    
    pageHeader = label.pageHeader;
    noResultsFound = label.noResultsFound;
    
    plpConfig;
    @track courses;
    @track selectedFilters = {
        course : 'All Courses',
        month : 'All Months',
        city : 'All Cities and Time Zones',
        deliveryFormat : 'All Delivery Formats',
        year : 'All Years'
    };
    @track filters;
    @track errorMessage = '';
    @track isLoading = true;
    @track hasCourses = false;

    connectedCallback() {
        this.loadChoices();
        this.loadCourses();
    }

    @wire(NavigationContext)
    navContext;

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getProductListingConfiguration,  {mapParams : {} })
    wiredProductConfig({ error, data }) {
        if (data) {
            this.plpConfig = data.plpConfig;
        } else if (error) {
            console.error(error);
        }
    };

    loadChoices() {
        getPicklists()
            .then(result => {
                const convertToLabelValue = (array) => {
                    return array.map(item => ({
                        label: item,
                        value: item
                    }));
                };

                this.filters = [
                    {
                        "name": "course",
                        "displayName": label.coursesLabel,
                        "values": convertToLabelValue(result.courses)
                    },
                    {
                        "name": "month",
                        "displayName": label.monthsLabel,
                        "values": convertToLabelValue(result.months)
                    },
                    {
                        "name": "city",
                        "displayName": label.citiesLabel,
                        "values": convertToLabelValue(result.cities)
                    },
                    {
                        "name": "deliveryFormat",
                        "displayName": label.deliveryFormatLabel,
                        "values": convertToLabelValue(result.deliveryFormats)
                    },
                    {
                        "name": "year",
                        "displayName": label.yearLabel,
                        "values": convertToLabelValue(result.years)
                    },
                ];
            })
            .catch(error => {
                this.errorMessage = error.body ? error.body.message : 'Unknown error';
            });
    }

    loadCourses() {
        this.isLoading = true;
        this.hasCourses = false;
        const monthTranslation = {
            January: 1, February: 2, March: 3, April: 4, May: 5, June: 6,
            July: 7, August: 8, September: 9, October: 10, November: 11, December: 12
        };

        let Month = this.selectedFilters.month;
        if (Month === 'All Months') {
            Month = null;
        } else {
            Month = monthTranslation[Month];
        }

        getAllCourses({
            course: this.selectedFilters.course,
            month: Month,
            city: this.selectedFilters.city,
            deliveryFormat: this.selectedFilters.deliveryFormat,
            year: this.selectedFilters.year
        })
            .then(result => {
                this.isLoading = false;
                this.courses = result;
                this.hasCourses = this.courses.length > 0;
            })
            .catch(error => {
                this.errorMessage = error.body ? error.body.message : 'Unknown error';
            });
    }

    handleInputChange(event) {
        this.selectedFilters = event.detail;
        this.loadCourses();
    }

    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + event.detail
            }
        });
    }

    handleClearAllFiltersEvent() {
        this.selectedFilters.course = 'All Courses';
        this.selectedFilters.month = 'All Months';
        this.selectedFilters.city = 'All Cities and Time Zones';
        this.selectedFilters.year = 'All Years';
        this.selectedFilters.deliveryFormat = 'All Delivery Formats';

        this.loadCourses();
    }

    handleOpenFiltersModal(evt) {
        evt.stopPropagation();
        evt.preventDefault();
        FiltersModal.open({
            label: label.modalLabel,
            filters: this.filters,
            selectedFilters: this.selectedFilters,
            onclearallfilters: (event) => this.handleClearAllFiltersEvent(),
            onfacetvalueupdate: (event) => this.handleInputChange(event),
            pageRef: this.currentPageReference,
        });
    }
}