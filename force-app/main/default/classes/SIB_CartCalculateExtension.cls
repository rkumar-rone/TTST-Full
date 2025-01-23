/**
* @description This is a sample orchestrator that calls the inventory, pricing, promotions, shipping and tax calculators.
* This class must extend CartExtension.CartCalculate and must be linked to the orchestrator extension point (Commerce_Domain_Cart_Calculate).
* Calculates pricing and promotions for operations: Add product to cart, remove product from cart, edit cart item quantity.
* Calculates promotions for operations: add coupon to cart, remove coupon from cart.
* Calculates pricing, promotions, inventory for start checkout operation (without shipping address available).
* Calculates pricing, promotions, inventory, shipping, post shipping and taxes for start checkout operation (with shipping address available).
* Calculates shipping, post shipping and taxes for update shipping address operation.
* Calculates taxes for select delivery method operation.
*/
global class SIB_CartCalculateExtension extends CartExtension.CartCalculate {

    /**
     * @description All classes extending CartExtension.CartCalculate must have a default constructor defined
     */
    global SIB_CartCalculateExtension() {
    }

    /**
     * @description Constructor used by unit tests only. See <<CartCalculateSampleUnitTest>>.
     * @param apexExecutor Executor which executes various calculators. Can be used to stub calculation results or delegate calculations to actual Calculator. See <<CartCalculateExecutorMock>>.
     */
    global SIB_CartCalculateExtension(final CartExtension.CartCalculateExecutorMock apexExecutor) {
        // Must call super constructor in order for provided Executor to be used for calculations
        super(apexExecutor);
    }

    // Each orchestrator must override this calculate method.
    global virtual override void calculate(CartExtension.CartCalculateOrchestratorRequest request) {

        CartExtension.Cart cart = request.getCart();

        // Use BuyerActions to decide which calculators to invoke
        CartExtension.BuyerActions buyerActions = request.getBuyerActions();
        System.debug('isCartItemChanged => '+ buyerActions.isCartItemChanged());
        System.debug('isCheckoutStarted => '+ buyerActions.isCheckoutStarted());
        System.debug('isCouponChanged => '+ buyerActions.isCouponChanged());
        System.debug('isDeliveryMethodSelected => '+ buyerActions.isDeliveryMethodSelected());
        System.debug('isRecalculationRequested => '+ buyerActions.isRecalculationRequested());
        System.debug('isRecalculationRequestedInCheckout => '+ isRecalculationRequestedInCheckout(buyerActions, cart));
        Boolean isCouponAppliedInCheckout = isCouponAppliedInCheckout(buyerActions, cart);
        Boolean runPricing = buyerActions.isCartItemChanged() ; // buyerActions.isCheckoutStarted() ||
        Boolean runPromotions = buyerActions.isCheckoutStarted() || buyerActions.isCouponChanged() || buyerActions.isCartItemChanged();
        Boolean runInventory = buyerActions.isCheckoutStarted();
        Boolean runShipping = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged()
                                || isCouponAppliedInCheckout;
        Boolean runPostShipping = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged()
                                || buyerActions.isDeliveryMethodSelected() || isCouponAppliedInCheckout;
        Boolean runTaxes = isRecalculationRequestedInCheckout(buyerActions, cart) || buyerActions.isDeliveryGroupChanged() ||
                            buyerActions.isDeliveryMethodSelected() || buyerActions.isCouponChanged() || isCouponAppliedInCheckout ;
        // OptionalBuyerActionDetails can be used to optimize the various calculators that are invoked
        CartExtension.CartCalculateCalculatorRequest calculatorRequest = new CartExtension.CartCalculateCalculatorRequest(cart, request.getOptionalBuyerActionDetails());
        System.debug('calculatorRequest => '+ calculatorRequest);
        System.debug('>>>>>runPricing>>>>>>>'+runPricing);
        if (runPricing)
        {
            runTaxes = false;
            System.debug('>>>>>Setting Tax to not call on Price Change>>>>>>>'+runTaxes);
            prices(calculatorRequest);
            System.debug('>>>>>cart.getId()>>>>>>>'+cart.getId());
            System.debug('>>>>>updateSessionPricesOnCart>>>>>>>');
            if(cart.getId() != null)
            {
                SIB_GetInfo.updateSessionPricesOnCart(cart.getId());
            }
            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),
                    CartExtension.CartValidationOutputTypeEnum.PRICING))
            {
                return;
            }
        }
        System.debug('>>>>>runPromotions>>>>>>>'+runPromotions);
        if (runPromotions)
        {
            promotions(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),
                    CartExtension.CartValidationOutputTypeEnum.PROMOTIONS))
            {
                return;
            }
        }

        if (runInventory)
        {
            inventory(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),
                    CartExtension.CartValidationOutputTypeEnum.INVENTORY))
            {
                return;
            }
        }

        if (runShipping)
        {
            shipping(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),
                    CartExtension.CartValidationOutputTypeEnum.SHIPPING))
            {
                return;
            }
        }

        if (runPostShipping)
        {
            postShipping(calculatorRequest);

            if (hasErrorLevelCartValidationOutput(cart.getCartValidationOutputs(),
                    CartExtension.CartValidationOutputTypeEnum.SYSTEM_ERROR))
            {
                return;
            }
        }
        System.debug('>>>>>runTaxes>>>>>>>'+runTaxes);
        if (runTaxes)
        {
            taxes(calculatorRequest);
        }
    }

    // This function evaluates whether there are errors in the CVO of a specific calculator type.
    private static Boolean hasErrorLevelCartValidationOutput(CartExtension.CartValidationOutputList cartValidationOutputs,
            CartExtension.CartValidationOutputTypeEnum cartValidationOutputType) {
        Iterator<CartExtension.CartValidationOutput> iterator = cartValidationOutputs.iterator();

        while (iterator.hasNext())
        {
            CartExtension.CartValidationOutput cvo = iterator.next();
            Boolean cvoContainsCalculatorError = cvo.getType() == cartValidationOutputType
                    && cvo.getLevel() == CartExtension.CartValidationOutputLevelEnum.ERROR;
            if (cvoContainsCalculatorError)
            {
                return true;
            }
        }
        return false;
    }

    private static Boolean isCouponAppliedInCheckout(CartExtension.BuyerActions buyerActions, CartExtension.Cart cart) {
        return cart.getStatus() == CartExtension.CartStatusEnum.CHECKOUT && buyerActions.isCouponChanged();
    }

    private static Boolean isRecalculationRequestedInCheckout(CartExtension.BuyerActions buyerActions, CartExtension.Cart cart) {
        return buyerActions.isRecalculationRequested() && CartExtension.CartStatusEnum.CHECKOUT == cart.getStatus();
    }
}