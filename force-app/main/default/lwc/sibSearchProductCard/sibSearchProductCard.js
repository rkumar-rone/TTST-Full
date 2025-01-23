import { LightningElement, api, track, wire } from 'lwc';
import { getFormFactor } from 'experience/clientApi';
import { isCmsResource, resolve } from 'experience/resourceResolver';
import { generateUrl, navigate, NavigationContext } from 'lightning/navigation';
import { AppContextAdapter, SessionContextAdapter } from 'commerce/contextApi';
import { createImageDataMap } from 'experience/picture';
import { calculateImageSizes, imageSizesDefined } from 'c/sibProductGalleryUtils';
import { CartStatusAdapter } from 'commerce/cartApi';
import { i18n } from './labels';
import SIBTheme from '@salesforce/resourceUrl/SIBTheme';

const SHOW_PRODUCT_EVT = 'showproduct';
const ADD_PRODUCT_TO_CART_EVT = 'addproducttocart';
const VARIATION = 'Variation';
const VARIATION_PARENT = 'VariationParent';
const SIMPLE = 'Simple';
const SET = 'Set';
const DEFAULT_MIN = 1;
const DEFAULT_MAX = 1000000;
const DEFAULT_INCREMENT = 1;

export default class SearchProductCard extends LightningElement {

    static renderMode = 'light';

    @wire(getFormFactor)
    formFactor;
    get isDesktop() {
        return this.formFactor === 'Large';
    }

    isQuantityValid = true;
    selectedQuantity;
    addingToCart = false;
    leftChildNames;
    rightChildNames;
    isShowMore = false;
    showMoreText;

    productImage = SIBTheme + '/images/Course-Default-Image.png';

    @api
    plpConfig;

    @api
    resultsLayout;

    @api
    set product(data) {
        this._product = data;
        this.updateCallToActionButtonUrl();
    }
    get product() {
        return this._product;
    }

    @api 
    tagList;

    @wire(SessionContextAdapter)
    sessionContext;

    @wire(AppContextAdapter)
    appContext;

    @wire(CartStatusAdapter)
    cartStatus;

    @wire(NavigationContext)
    wiredNavigationContext(context) {
        this._navigationContext = context;
        this.updateCallToActionButtonUrl();
    }

    get showCallToActionButton() {
        return this.plpConfig?.showCallToActionButton;
    }

    get showProductImage() {
        return this.plpConfig?.showProductImage;
    }

    get viewOptionsButtonText() {
        return this.plpConfig?.viewOptionsButtonText;
    }

    get learnMoreButtonText() {
        if(this.isCartProcessing && this.addingToCart && this.addToCartButtonProcessingText) {
            return this.addToCartButtonProcessingText;
        }else {
            this.addingToCart = false;
        }
        return this.plpConfig?.addToCartButtonText;
    }

    get addToCartButtonStyle() {
        return this.plpConfig?.addToCartButtonStyle;
    }

    get addToCartButtonProcessingText() {
        return this.plpConfig?.addToCartButtonProcessingText;
    }

    get showTag(){
        if(this.tagList && this.tagList.length > 0){
            return true;
        }
        return false;
    }

    get productName() {
        return this.product?.name;
    }

    get productSku() {
        return this.product?.productSku;
    }

    get shortDescription() {
        if(!this.isDesktop && this.product?.productGroup && (this.product?.productGroup === i18n.selfStudyLabel || this.product?.productGroup === i18n.bundleLabel)) {
            return;
        }
        return this.product?.fieldsMap['Short_Description__c'];
    }

    get parentPrice(){
        return this.product?.fieldsMap['SIB_PC_Parent_Price__c'];
    }

    get parentProduct(){
        return this.product?.productClass == VARIATION_PARENT
    }

    get displayPriceText() {
        if(this.product?.productGroup && (this.product?.productGroup === i18n.selfStudyLabel || this.product?.productGroup === i18n.bundleLabel)) {
            return;
        }
        return this.product?.price['priceLabel'];
    }

    get attributes() {
        return this.product?.variationAttributeSet?.attributes;
    }

    get productGroup() {
        if(this.product?.isCourse) {
            return i18n.courseName;
        }
        return this.product?.productGroup;
    }

    get mostPopularTag() {
        if(this.product?.isMostPopular) {
            return {
                isPopular : true,
                popularLabel : i18n.mostPopularName
            };
        }
        return {
            isPopular : false
        };
    }

    get newCourseTag() {
        if(this.product?.isNewCourse) {
            return {
                hasNewCourse : true,
                newCourseLabel : i18n.newCourseName
            };
        }
        return {
            hasNewCourse : false
        };
    }

    get productBgDiv() {
        if(this.product?.isCourse) {
            return 'plp-image-section plp-blue-bg-color';
        }
        return 'plp-image-section plp-green-bg-color';
    }

    get eventRelationshipChildNames() {
        const allItems = this.product?.bundleEventChildNames;
        if(allItems) {
            if(allItems?.length < 3) {
                this.leftChildNames = allItems?.slice(0, allItems?.length);
            }else if(allItems?.length < 5) {
                this.leftChildNames = allItems?.slice(0, 2);
                this.rightChildNames = allItems?.slice(2, allItems?.length);
            }else {
                this.leftChildNames = allItems?.slice(0, 2);
                this.rightChildNames = allItems?.slice(2, 4);
            }

            if(this.isDesktop) {
                this.isShowMore = allItems?.length > 4;
                if(this.isShowMore) {
                    this.showMoreText = '+' + (allItems.length - 4) + ' more';
                }
            }else {
                this.leftChildNames = allItems?.slice(0, 3);
                this.rightChildNames = undefined;
                this.isShowMore = allItems?.length > 3;
                if(this.isShowMore) {
                    this.showMoreText = '+' + (allItems.length - 3) + ' more';
                }
            }
        }

        return this.product?.bundleEventChildNames;
    }

    connectedCallback(){
    }

    renderedCallback() {
        calculateImageSizes(this.querySelector('.imageArea'), this._imageSizes);
    }

    @api
    focus() {
        if (this.showCallToActionButton) {
            const focusTarget = this.querySelector('c-common-link') || this.querySelector('c-common-button');
            focusTarget?.focus();
        }
    }
    
    get fields() {
        let fieldList = [];

        let tempFieldMap = {};
        for (let keys in this.product.fieldsMap) {
            tempFieldMap[keys.toLowerCase()] = this.product.fieldsMap[keys];
        }

        this.plpConfig?.cardContentMapping.forEach(element => {
            let field = {
                showLabel: element.showLabel,
                label: element.label,
                value: tempFieldMap[element.name],
                hasValue: tempFieldMap[element.name] ? true : false
            }
            fieldList.push(field);
        });

        return fieldList;

    }

    get addToCartButtonAriaLabel() {
        if (this.product?.name) {
            return i18n.addToCartAriaLabel.replace('{productTitle}', this.product.name);
        }
        return '';
    }

    get viewOptionsButtonAriaLabel() {
        if (this.product?.name) {
            return i18n.viewOptionsAriaLabel.replace('{productTitle}', this.product.name);
        }
        return '';
    }

    get image() {
        calculateImageSizes(this.querySelector('.imageArea'), this._imageSizes);
        const img = this.product?.defaultImage;
        return {
            alternateText: img?.altText ?? '',
            url: img?.url?.includes('default-product-image')
                ? this.productImage
                : resolve(img?.url ?? '', false, {
                    height: 460,
                    width: 460,
                }),
            images:
                img?.url && isCmsResource(img?.url) && imageSizesDefined(this._imageSizes)
                    ? createImageDataMap(img.url, this._imageSizes, [1, 2])
                    : [],
        };
    }

    get isGridLayout() {
        return this.resultsLayout === 'grid';
    }

    get actionButtonVariant() {
        return ['primary', 'secondary', 'tertiary'].includes(this.addToCartButtonStyle) ? this.addToCartButtonStyle : 'primary';
    }

    handleValueChanged(evt) {
        this.isQuantityValid = evt.detail.isValid;
        this.selectedQuantity = evt.detail.value;
    }

    get quantityRules() {
        if (this.plpConfig?.showQuantitySelector) {
            return {
                minimum: DEFAULT_MIN.toString(),
                maximum: DEFAULT_MAX.toString(),
                increment: DEFAULT_INCREMENT.toString(),
            };
        }
        return  this.product?.quantityRule;
    }

    get quantityRuleMinimum() {
        return this.quantityRules?.minimum;
    }

    get quantityRuleMaximum() {
        return this.quantityRules?.maximum;
    }

    get quantityRuleIncrement() {
        return this.quantityRules?.increment;
    }

    get minimumText() {
        const min = Number.parseInt(this.quantityRules?.minimum ?? '', 10);
        return this.plpConfig?.minimumQuantityGuideText?.replace('{0}', `${min}`);
    }

    get maximumText() {
        const max = Number.parseInt(this.quantityRules?.maximum ?? '', 10);
        return this.configuration?.maximumQuantityGuideText?.replace('{0}', `${max}`);
    }

    get incrementText() {
        const increment = Number.parseInt(this.quantityRules?.increment ?? '', 10);
        return this.configuration?.incrementQuantityGuideText?.replace('{0}', `${increment}`);
    }

    get quantityRuleCombinedText() {
        const rules = [this.minimumText, this.maximumText, this.incrementText];
        return rules.filter((item) => item).join(' • ');
    }

    get quantitySelectorLabelText() {
        return this.plpConfig?.quantitySelectorLabelText;
    }

    get addToCartButtonDisabled() {
        return this.isCartProcessing || !this.isQuantityValid;
    }

    get isCartProcessing() {
        //Commented due to issue that isProcessing is always returing true
        return this.cartStatus?.data?.isProcessing || this.cartStatus?.loading;
        //return false;
    }

    get isSubscriptionProduct() {
        return this.product?.isSubscription ?? false;
    }
    get subscriptionOptionsLabelText() {
        return i18n.subscriptionOptionLabel;
    }

    get isCTAButtonViewOptions() {
        return (
            this.product?.productClass === VARIATION_PARENT || this.product?.productClass === SET ||
            ((this.product?.productClass === SIMPLE || this.product?.productClass === VARIATION) && 
            Boolean(this.quantityRules) && !this.plpConfig?.showQuantitySelector) ||
            this.isSubscriptionProduct
        );
    }

    get isCTAButtonAddToCart() {
        return (
            this.product?.productClass === SIMPLE || this.product?.productClass === VARIATION 
        );
    }

    get showInlineQuantitySelector() {
        return !!(this.quantityRules && this.plpConfig?.showQuantitySelector);
    }

    get showInlineQuantitySelectorText() {
        return !!(
            !this.isCTAButtonViewOptions &&
            this.plpConfig?.showQuantitySelector &&
            this.plpConfig?.showQuantityRulesText &&
            this.product?.quantityRule
        );
    }

    handleProductDetailPageNavigation(event) {
        event.preventDefault();
        const productId = this.product?.productSlugURL != null ? this.product?.productSlugURL : this.product?.productId;
        const productName = this.product?.name;

        this.dispatchEvent(
            new CustomEvent(SHOW_PRODUCT_EVT, {
                detail: {
                    productId,
                    productName,
                },
            })
        );
    }

    get quantitySelectorClassList() {
        const classes = [];
        if (this.showInlineQuantitySelector) {
            classes.push('quantitySelectorContainer');
            if (this.isGridLayout) {
                classes.push('stacked');
            }
        }
        return classes.join(' ');
    }

    get isAddToCartEnabled() {
        const isLoggedIn = Boolean(this.sessionContext?.data?.isLoggedIn);
        const guestCartEnabled = Boolean(this.appContext?.data?.guestCartEnabled);
        return isLoggedIn || guestCartEnabled;
    }
    
    handleAddToCart() {
        if (!this.isAddToCartEnabled) {
            this.navigateToLogin();
            return;
        }
        if (this.isCartProcessing) {
            return;
        }
        const productId = this.product?.productId;
        const quantity = this.selectedQuantity ? this.selectedQuantity : 1;
        this.addingToCart = true;
        this.dispatchEvent(
            new CustomEvent(ADD_PRODUCT_TO_CART_EVT, {
                detail: {
                    productId,
                    quantity,
                },
            })
        );

    }

    handleKeydown(evt) {
        if (evt.key === 'Enter') {
            this.handleProductDetailPageNavigation(evt);
        }
    }

    navigateToLogin() {
        navigate(this._navigationContext, {
            type: 'comm__namedPage',
            attributes: {
                name: 'Login',
            },
        });
    }

    updateCallToActionButtonUrl() {
        if (this._navigationContext && this?._product?.productId) {
            this._productUrl = generateUrl(this._navigationContext, {
                type: 'standard__recordPage',
                attributes: {
                    objectApiName: 'Product2',
                    recordId: this._product.productId,
                    actionName: 'view',
                },
            });
        }
    }

    _product;
    _navigationContext;
    _productUrl;

    @track
    _imageSizes = {
        mobile: 0, tablet: 0, desktop: 0,
    };

}