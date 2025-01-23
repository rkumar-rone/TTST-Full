/*
 * Copyright (c) 2023, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: Apache-2.0
 * For full license text, see the LICENSE file in the repo
 * root or https://opensource.org/licenses/apache-2-0/
 */
import actionViewCart from '@salesforce/label/c.Product_ModalAddToCart_actionViewCart';
import actionContinueShopping from '@salesforce/label/c.Product_ModalAddToCart_actionContinueShopping';
import messageSuccessfullyAddedToCart from '@salesforce/label/c.Product_ModalAddToCart_messageSuccessfullyAddedToCart';
import coulNotAddToCartDueToCurrencyMismatch from '@salesforce/label/c.SIB_CouldNotAddToCartDueToCurrencyMismatch';;
import addToCartSuccessMessage from '@salesforce/label/c.SIB_AddToCartSuccessMsg';
import productCouldNotBeAddedToCart from '@salesforce/label/c.SIB_ProductCouldNotBeAddedToCart';
import SIB_Currency_Change_Msg from '@salesforce/label/c.SIB_Currency_Change_Msg';
import chooseYourCourse from '@salesforce/label/c.SIB_ChooseYourCourse';


/**
 * Internationalization labels.
 */
export const Labels = {
    /**
     * A label of the form "View Cart".
     * @type {string}
     */
    actionViewCart,
    /**
     * A label of the form "Continue Shopping".
     * @type {string}
     */
    actionContinueShopping,
    /**
     * A label of the form "Item was added to cart".
     * @type {string}
     */
    messageSuccessfullyAddedToCart,

    /**
     * A label for text "Could not add this product to Cart because there are items in the cart with a different currency."
     */
    coulNotAddToCartDueToCurrencyMismatch,

    /**
     * A label for text "Your cart has been updated."
     */
    addToCartSuccessMessage,

    /**
     * A label for text "{0} could not be added to your cart at this time. Please try again later."
     */
    productCouldNotBeAddedToCart,
    SIB_Currency_Change_Msg,
    chooseYourCourse
};