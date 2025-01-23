import { LightningElement, track, api } from 'lwc';
import labels from './labels';
import { debounce } from 'experience/utils';
import { refinementsFromFacetsMap } from './dataConverter';
import { EVENT } from './constants';
import { dispatchAction } from 'commerce/actionApi';
/**
 * @typedef {import('../searchResults/searchResults').SearchFacet} SearchFacet
 */

/**
 * @typedef {import('../searchResults/searchResults').FiltersPanelDetail} FiltersPanelDetail
 */

/**
 * @typedef {import('../searchResults/searchResults').CategoryInfoTree} CategoryInfoTree
 */

/**
 * @typedef {import('../searchFilters/searchFilters').ProductSearchRefinement} ProductSearchRefinement
 */

/**
 * @typedef {import('../searchFilters/searchFilters').SearchFacetValuesCheckMap} SearchFacetValuesCheckMap
 */

/**
 * An event fired when the facet value been updated.
 * @event SearchFiltersPanel#facetvalueupdate
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {SearchFacet} detail.mruFacet
 *   The most recent facet that the user has selected.
 * @property {ProductSearchRefinement[]} detail.refinements
 *   The selected filter id and it's values.
 */

/**
 * An event fired to clear all filters
 * @event SearchFiltersPanel#clearallfilters
 * @type {CustomEvent}
 */
/**
 * Representation for the Filters Panel which shows the category tree and facets
 * @fires SearchFiltersPanel#facetvalueupdate
 * @fires SearchFiltersPanel#clearallfilters
 */

/**
 * An event fired when the user changes the sort rule/order.
 * @event BuilderSortMenu#SearchSortEvent
 * @type {CustomEvent}
 * @property {object} detail CustomEvent details
 * @property {string} [detail.type] The action ID
 * @property {string} [detail.payload] The action payload, i.e. selected sort rule ID
 */

/**
 * A UI control for user to select the sort order for search result
 * @slot sortMenuLabel
 * @fires BuilderSortMenu#SearchSortEvent
 */
export default class SearchFiltersPanel extends LightningElement {
    static renderMode = 'light';

    @api
    isClearAllClick;

    /**
     * Gets or sets the filters panel display-data.
     * @type {?FiltersPanelDetail}
     */
    @api
    get displayData() {
        return this._displayData;
    }
    set displayData(value) {
        if(this.isClearAllClick) {
            //Clearing all checkboxes to False
            const filterInputs = this.querySelectorAll('.plpFilter');
            filterInputs.forEach((node) => {
                // Set checked to false
                node.checked = false;
            });

            this.initialFacets = [];
            this._facetsMap.clear();
            this._mruFacet = {};
        }
        this._displayData = value;
        const facets = value?.filters ?? [];
        this._facetsMap = this._createFacetMap(facets);
    }
    /**
     * Gets the normalized filters panel display-data.
     * @type {FiltersPanelDetail}
     * @private
     */
    get normalizedDisplayData() {
        const displayData = this.displayData;
        return {
            filters: displayData?.filters ?? [],
            categories: displayData?.searchCategory,
        };
    }

    @track
    initialFacets = [];

    /**
     * Gets the list of facets
     * @type {?SearchFacet[]}
     * @private
     */
    get facets() {
        if(this.initialFacets.length == 0) {
            this.initialFacets = this.normalizedDisplayData.filters;
            return this.initialFacets;
        }else {
            //traverse initial facets and mark refinements as checked
            this.initialFacets = this.normalizedDisplayData.filters.map((facet) => {
                // Clone the facet to avoid mutating the original
                let clonedFacet = { ...facet };

                // Get all selected filter values from the UI
                const filterInputs = this.querySelectorAll('.plpFilter');
                let selectedValues = [];
                filterInputs.forEach((node) => {
                    if (node.checked == true) {
                        selectedValues.push(node.dataset.id);
                    }
                });

                if (this._mruFacet && this._mruFacet.nameOrId === facet.nameOrId) {
                    const mruValues = (this._mruFacet || {}).values || [];
                    const facetValues = (facet || {}).values || [];

                    // Merge mruValues and facetValues into a Map
                    const mergedMap = [...mruValues, ...facetValues].reduce(
                        (map, value) => {
                            map.set(value.nameOrId, { ...value });
                            return map;
                        },
                        new Map()
                    );

                    // Update the `checked` property in the mergedMap
                    mergedMap.forEach((value, key) => {
                        if (selectedValues.includes(key)) {
                            // If key exists in selectedValues, set checked to true
                            value.checked = true;
                        }
                    });

                    clonedFacet = {
                        ...facet,
                        values: Array.from(mergedMap.values())
                    };
                } else {
                    // Iterate over clonedFacet.values and check selectedValues
                    clonedFacet.values = clonedFacet.values.map((value) => {
                        if (selectedValues.includes(value.nameOrId)) {
                            // If the value.nameOrId exists in selectedValues, set checked to true
                            return {
                                ...value,
                                checked: true,
                            };
                        }
                        return value;
                    });
                }
                return clonedFacet;  // Return cloned and modified facet
            });
        }
        return this.initialFacets;
    }

    /**
     * Gets the categories tree
     * @type {?CategoryInfoTree}
     * @private
     */
    get categories() {
        return this.normalizedDisplayData.categories;
    }

    /**
     * Gets the label for the filters header
     * @type {string}
     * @private
     */
    get filtersHeader() {
        return labels.filtersHeader;
    }

    /**
     * The map of all SearchFacetValuesCheckMap and all their possible facet values, regardless of selection or not.
     * @type {Map<string | undefined, SearchFacetValuesCheckMap> | null}
     */
    _facetsMap;

    /**
     * The most recent facet that the user has selected
     * @type {SearchFacet}
     * @private
     */
    _mruFacet = {};

    /**
     * The ID of the most recent facet that the user has selected
     * @type {?string}
     * @private
     */
    _mruFacetId;

    /**
     * The filters panel display-data.
     * @type {?FiltersPanelDetail}
     * @private
     */
    _displayData;

    /**
     * Handler for the 'onfacetvaluetoggle' event fired from inputFacet
     * @param {CustomEvent} evt the event object
     */
    handleFacetValueToggle(evt) {
        if (evt.target instanceof HTMLElement) {
            this._mruFacetId = evt.detail.facetId;
            const facetValueId = evt.detail.id;
            const checked = evt.detail.checked;
            if (this._mruFacetId && this._facetsMap?.get(this._mruFacetId)) {
                this._facetsMap.get(this._mruFacetId)?.valuesCheckMap.set(facetValueId, checked);
                this._facetValueUpdated();
            }
        }
    }
    _createFacetMap(facets) {
        return facets?.reduce((facetAccumulator, searchFacet) => {
            return facetAccumulator.set(searchFacet.nameOrId, {
                searchFacet,
                valuesCheckMap: new Map(searchFacet.values?.map((facetValue) => [facetValue.nameOrId, facetValue.checked])),
            });
        }, new Map());
    }

    /**
     * The function called when we update the facets in the search
     * @type {Function}
     * @private
     * @fires SearchFiltersPanel#facetvalueupdate
     */
    _facetValueUpdated = debounce(() => {
        const mruFacetList = this.facets?.filter((facet) => facet.nameOrId === this._mruFacetId);
        if (mruFacetList && mruFacetList.length === 1) {
            this._mruFacet = mruFacetList[0];
        }
        const updatedMruFacet = Object.assign({}, this._mruFacet);
        updatedMruFacet.values = updatedMruFacet.values.map((item) => {
            return {
                ...item,
                checked: this._facetsMap?.get(this._mruFacetId)?.valuesCheckMap.get(item.nameOrId),
            };
        });
        this._mruFacet = updatedMruFacet;
        //let refinements = refinementsFromFacetsMap(this._facetsMap);
        let refinements = [];
        //fetch all checked filters
        const filterInputs = this.querySelectorAll('.plpFilter');
        let facetValueMap = {};
        let facetTypeMap = {};
        filterInputs.forEach((node) => {
            if(node.checked == true) {
                let selectedValues = facetValueMap[node.dataset.facetid];
                if(selectedValues == undefined) {
                    selectedValues = [];
                }
                selectedValues.push(node.dataset.id);
                facetValueMap[node.dataset.facetid] = selectedValues;
                facetTypeMap[node.dataset.facetid] = node.dataset.facettype;
            }
        });
        if(Object.keys(facetValueMap).length > 0) {
            for(var k in facetValueMap) {
                refinements.push({
                    "nameOrId": k,
                    "type": "DistinctValue",
                    "attributeType": facetTypeMap[k],
                    "values": facetValueMap[k] 
                });
            }
        }

        this.dispatchEvent(
            new CustomEvent(EVENT.FACETVALUE_UPDATE_EVT, {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: {
                    mruFacet: this._mruFacet,
                    refinements,
                },
            })
        );
    }, 300);

    /**
     * Handler for the 'click' event fired from the Clear All button
     * Resets the facetsMap and triggers the 'clearallfilters' event
     * @param {CustomEvent} evt the event object
     * @fires SearchFiltersPanel#clearallfilters
     */
    handleClearAll(evt) {
        //evt.preventDefault();
        dispatchAction(this, handleClearAll(this._facetsMap));
        evt.preventDefault();
    }
}