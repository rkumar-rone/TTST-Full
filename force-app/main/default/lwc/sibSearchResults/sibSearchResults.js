import { api, LightningElement } from 'lwc';
import { generateStyleProperties, generateThemeTextSizeProperty } from 'experience/styling';

function dxpTextSize(textSize) {
    const themeSize = generateThemeTextSizeProperty(`heading-${textSize}`);
    return themeSize ? `var(${themeSize}-font-size)` : 'initial';
}

// export const DEFAULTS = {
//     cardAlignment: 'center',
//     cardBackgroundColor: 'var(--dxp-g-root)',
//     cardBorderColor: 'var(--dxp-g-root)',
//     cardBorderRadius: '1px',
//     cardDividerColor: 'var(--dxp-g-neutral)',
//     gridColumnSpacing: 'small',
//     gridMaxColumnsDisplayed: 3,
//     gridRowSpacing: 'small',
//     listRowSpacing: 'small',
//     negotiatedPriceTextColor: 'var(--dxp-g-root-contrast)',
//     negotiatedPriceTextSize: 'medium',
//     originalPriceTextColor: 'var(--dxp-g-root-contrast)',
//     originalPriceTextSize: 'medium',
//     resultsLayout: 'grid',
// };

const SHOW_PRODUCT_EVT = 'showproduct';
const ADD_PRODUCT_TO_CART_EVT = 'addproducttocart';
const PAGE_CHANGE_GOTOPAGE_EVT = 'pagegoto';
const UPDATE_CURRENT_PAGE_EVT = 'updatecurrentpage';
export default class SearchResults extends LightningElement {

    static renderMode = 'light';

    @api 
    plpConfig;

    @api
    resultsLayout;
    
    @api
    searchResults;

    @api
    isPaginationClick;
   
    handleAddToCart(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(ADD_PRODUCT_TO_CART_EVT, {
                detail: event.detail,
            })
        );
    }

    handleNavigateToProductPage(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(SHOW_PRODUCT_EVT, {
                detail: event.detail,
            })
        );
    }
    
    handleGotoPageEvent(event) {
        event.stopPropagation();
        this.dispatchEvent(
            new CustomEvent(PAGE_CHANGE_GOTOPAGE_EVT, {
                detail: event.detail,
                composed:true,
                bubbles:true
            })
        );
    }
    
}