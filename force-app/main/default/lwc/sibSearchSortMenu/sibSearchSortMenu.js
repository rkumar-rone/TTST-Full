import { api, LightningElement } from 'lwc';

const EVENT_SORT_ORDER_CHANGED = 'searchsort';
export default class SearchSortMenu extends LightningElement {
    static renderMode = 'light';

    _sortRules;

    _options = [];
    sortRuleId;

    @api
    set sortRules(value) {
        console.log('sortRules--->'+JSON.stringify(value));
        this._sortRules = value;
        this._options = this.computeSortOptions(value);
    }
    get sortRules() {
        return this._sortRules;
    }
    
    get activeOption() {
        const selectedOption = this._options.find((sortOption) => sortOption.order === 1);
        this.sortRuleId = selectedOption.sortRuleId;
        return (
            selectedOption ||
            this._options.at(0) || {
                label: '',
                value: '',
            }
        );
    }

    computeSortOptions(sortRules) {
        let sortRulesArray = [];

        sortRules.forEach(element => {
            let rule = {
                value: element.sortRuleId,
                label: element.displayName,
                order: element.sortOrder
            }
            sortRulesArray.push(rule);
        });

        console.log('sortRulesArray:'+JSON.stringify(sortRulesArray));
        return sortRulesArray;
    }

    handleChange({ detail: { value } }) {
        if (value && value !== this.sortRuleId) {
            this.dispatchEvent(
                new CustomEvent(EVENT_SORT_ORDER_CHANGED, {
                    bubbles: true,
                    cancelable: true,
                    composed: true,
                    detail: {
                        sortRuleId: value,
                    },
                })
            );
        }
    }
}