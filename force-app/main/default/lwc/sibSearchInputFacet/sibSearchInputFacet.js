import { api, LightningElement } from 'lwc';
import { NUM_FACETVALUES_ALWAYS_DISPLAYED, FACETVALUE_SHOW_MORE_LIMIT } from './constants';
import generateLabel from './inputFacetLabelGenerator';
/**
 * @typedef {import('../searchResults/searchResults').DistinctFacetValue} DistinctFacetValue
 */
export default class SearchInputFacet extends LightningElement {
    static renderMode = 'light';

    /**
     * The values of the facet
     * @type {?DistinctFacetValue[]}
     */
    @api
    values;

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * @type {DistinctFacetValue[]}
     */
    get normalizedValues() {
        return this.values || [];
    }

    /**
     * The type of facet being displayed
     * @type {?string}
     */
    @api
    type;

    /**
     * The facet name for the values being displayed
     * @type {?string}
     */
    @api
    facetName;

    @api
    facetType;

    /**
     * Determines whether we show all the facet's values or not
     * @type {boolean}
     * @private
     */
    _expanded = false;

    /**
     * Gets the defaulted / normalized sequence of facet values to display.
     * Only show the first 6 values if
     * @type {DistinctFacetValue[]}
     * @readonly
     * @private
     */
    get displayedValues() {
        let facetValues = Array.from(this.normalizedValues);
        if (this.displayShowMore && !this._expanded) {
            facetValues = facetValues.slice(0, NUM_FACETVALUES_ALWAYS_DISPLAYED);
        } else if (this.displayShowMore && this._expanded) {
            facetValues = facetValues.map((facetValue, index) => ({
                ...facetValue,
                focusOnInit: index === NUM_FACETVALUES_ALWAYS_DISPLAYED,
            }));
        }
        return facetValues;
    }

    /**
     * Gets whether we should display a "Show More" button or not
     * @type {boolean}
     * @readonly
     * @private
     */
    get displayShowMore() {
        return this.normalizedValues.length > FACETVALUE_SHOW_MORE_LIMIT;
    }

    /**
     * Gets the label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get showMoreOrLessLabel() {
        return generateLabel(this._expanded);
    }

    /**
     * Gets the aria label for the 'Show More' or 'Show Less' button
     * @type {string}
     * @readonly
     * @private
     */
    get facetAriaLabel() {
        return generateLabel(this._expanded, this.facetName);
    }

    /**
     * Handle the 'click' event fired from the 'Show More' or 'Show Less' button
     * @private
     */
    handleShowMoreOrLess(event) {
        event.preventDefault();
        this._expanded = !this._expanded;
    }
}