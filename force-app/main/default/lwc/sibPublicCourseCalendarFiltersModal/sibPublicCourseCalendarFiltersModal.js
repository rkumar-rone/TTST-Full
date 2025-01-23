import { LightningElement, api } from 'lwc';
import clearButton from '@salesforce/label/c.Search_Facets_clearButton';
import cancelButton from '@salesforce/label/c.Search_Facets_cancelButton';
import LightningModal from 'lightning/modal';

export default class SibPublicCourseCalendarFiltersModal extends LightningModal {
    
    @api
    selectedFilters;
    
    @api
    filters;

    /**
     * The current page reference
     * @type {PageReference}
     */
    @api
    pageRef;

    isClearAll = false;

    labels = {
        clearButton,
        cancelButton
    }

    handleClearAllFilters() {
        this.resetFilters();
        this.isClearAll = true;
        this.dispatchEvent(
            new CustomEvent('clearallfilters', {
                bubbles: true,
                composed: true,
                cancelable: false,
            })
        );
    }

    handleInputChange(event) {
        this.isClearAll = false;
        this.dispatchEvent(
            new CustomEvent('facetvalueupdate', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: event.detail,
            })
        );
    }

    resetFilters() {
        this.selectedFilters = {
            course : 'All Courses',
            month : 'All Months',
            city : 'All Cities and Time Zones',
            year : 'All Years',
            deliveryFormat : 'All Delivery Formats'
        };
    }

    /**
     * Handles click on the close button
     * @fires SearchFiltersModalPanel#closesearchfiltersmodal
     */
    handleCloseModal() {
        this.close();
    }
}