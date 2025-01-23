import LightningModal from 'lightning/modal';
import { api } from 'lwc';
/**
 * @typedef {{[key: string]: *}} PageReference
 */

/**
 * @typedef {import('../searchResults/searchResults').FiltersPanelDetail} FiltersPanelDetail
 */

/**
 * @typedef {import('../searchResults/searchResults').ProductSearchResultSummary} ProductSearchResultSummary
 */
export default class SearchFiltersModal extends LightningModal {
    /**
     * The search results data
     * @type {?ProductSearchResultSummary}
     */
    @api
    displayData;

    /**
     * The current page reference
     * @type {PageReference}
     */
    @api
    pageRef;

    /**
     * The facets panel details to pass to the modal
     * @type {FiltersPanelDetail}
     * @private
     * @readonly
     */
    get normalizedDisplayData() {
        return this.displayData ?? {};
    }

    /**
     * Gets the total count of product items.
     * @type {number}
     * @readonly
     * @private
     */
    get totalItemCount() {
        return this.displayData?.total ?? 0;
    }
    handleClose() {
        this.close();
    }
}