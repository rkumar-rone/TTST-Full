import { LightningElement, api } from 'lwc';
export default class SibPublicCourseCalendarFiltersPanel extends LightningElement {
    static renderMode = 'light';

    @api
    selectedFilters;

    @api
    filters;

    _isClearAll;

    @api
    get isClearAll() {
        return _isClearAll;
    }
    set isClearAll(value) {
        this._isClearAll = value;
        if(value && value === true) {
            this.selectedFilterCSSChange(this.selectedFilters);
        }
    }

    alreadyApplied = false;

    handleFacetValueUpdateEvent(event) {
        event.preventDefault();

        // Update the specific filter in the selectedFilters object
        this.selectedFilters = {
            ...this.selectedFilters,
            [event?.target?.dataset?.filtername] : event?.target?.dataset?.value   // Dynamically update the property based on the combobox name
        };

        this.selectedFilterCSSChange(this.selectedFilters);

        this.dispatchEvent(
            new CustomEvent('facetvalueupdate', {
                bubbles: true,
                composed: true,
                cancelable: true,
                detail: { ...this.selectedFilters },
            })
        );
    }

    applyCssToSelectedFilters() {
        if(!this.alreadyApplied) {
            this.selectedFilterCSSChange(this.selectedFilters);
            this.alreadyApplied = true;
        }
    }

    selectedFilterCSSChange(selectedFilters) {
        if(this.filters) {
            let filterValues = Object.values(selectedFilters);
        
            // Function to handle item selection
            const filterValueElements = this.querySelectorAll('.filter-value');
            
            if(filterValueElements) {
                // Iterate over NodeList
                filterValueElements.forEach(filterValue => {

                    const value = filterValue.dataset.value;

                    // Check if the filter value is in the selectedFilters
                    if (filterValues.includes(value)) {
                        filterValue.classList.add('selected-filter');
                    } else {
                        filterValue.classList.remove('selected-filter');
                    }
                });
            }
        }
    }

    /**
     * Handle the keydown event from categoryTree
     * @param {KeyboardEvent} evt the event object
     */
    handleKeydown(evt) {
        if (evt.key === 'Enter') {
            this.handleFacetValueUpdateEvent(evt);
        }
    }
}