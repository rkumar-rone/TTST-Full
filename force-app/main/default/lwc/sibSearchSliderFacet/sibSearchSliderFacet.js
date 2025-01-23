import { LightningElement, api } from 'lwc';
export default class SearchSliderFacet extends LightningElement {
    static renderMode = 'light';

    /**
     * The id of the facet
     * @type {?string}
     */
    @api
    facetId;

    /**
     * The minimum value count for the slider
     * @type {?number}
     */
    @api
    min;

    /**
     * The maximum value count for the slider
     * @type {?number}
     */
    @api
    max;
}