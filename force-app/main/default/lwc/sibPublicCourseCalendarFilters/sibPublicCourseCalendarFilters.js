import { LightningElement, api, wire } from 'lwc';
import { Labels } from './labels';
import { getFormFactor } from 'experience/clientApi';

export default class SibPublicCourseCalendarFilters extends LightningElement {

    static renderMode = 'light';

    @wire(getFormFactor)
    formFactor;
    get isDesktop() {
        return this.formFactor === 'Large';
    }

    @api
    selectedFilters;

    @api
    filters;

    isClearAll = false

    /**
     * The title for the mobile button
     * @type {string}
     * @readonly
     */
    filterHeaderLabel = Labels.filterHeader;

    /**
     * The title for the Clear All button
     * @type {string}
     * @readonly
     */
    clearAllLabel = Labels.clearAllLabel;
    
    /**
     * Handles opening the filters modal while on mobile only
     * @param {CustomEvent} event click event
     * @fires SearchFilters#openmodal
     */
    handleOpenSearchFiltersModal(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent('openmodal', {
                bubbles: true,
                composed: true,
                cancelable: true,
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

    handleClearAllFilters() {
        this.isClearAll = true;
        this.dispatchEvent(
            new CustomEvent('clearallfilters', {
                bubbles: true,
                composed: true,
                cancelable: false,
            })
        );
    }
}