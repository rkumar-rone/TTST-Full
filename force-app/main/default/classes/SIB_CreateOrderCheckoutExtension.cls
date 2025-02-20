/**
 * @description       : Custom extension class to handle post order creation customization
 * @author            : vramachandran@rafter.one
 * @group             : 
 * @last modified on  : 10-17-2024
 * @last modified by  : vramachandran@rafter.one
**/
public class SIB_CreateOrderCheckoutExtension extends CartExtension.CheckoutCreateOrder {

    @TestVisible private SIB_OrderDetailsWrapper dataWrapper;
    @TestVisible private CartExtension.Cart cart;
    @TestVisible private CartExtension.CreateOrderResponse response;
    @TestVisible private CartExtension.OrderGraph orderGraph;
    @TestVisible private Order order;
    
    @TestVisible List<OrderItem> updatedOrderItemList;

    @TestVisible private Boolean isBundleProductAvailable = false;

    @TestVisible private Id paymentMethodId;
    
    public override CartExtension.CreateOrderResponse createOrder(CartExtension.CreateOrderRequest request) {

        try{

            prepareRecievedData(request);
            List<OrderItem> orderItems = this.orderGraph.getOrderItems();//get order items from order graph      
            
            getWrapperDataFromOrderItem(orderItems); //get data parsed for processing
            getBundleItemsList();//check if bundle products are available

            //if bundle products are found, create new order items of type delivery charge and add to order graph
            if(this.isBundleProductAvailable && null != this.dataWrapper?.orderItemProdIdToBundleItemMap
                && !this.dataWrapper?.orderItemProdIdToBundleItemMap.isEmpty()) {
                handleBundledOrderItemCreation(orderItems);
            }

            updateOrderRecord();//Update order record, any customization for order is added here
            
            
        }catch(Exception e) {
            // logger to be implemented to handle 
        }
        
        return response;
    }

    @TestVisible
    private void prepareRecievedData(CartExtension.CreateOrderRequest request) {
        this.cart = request.getCart();
        this.response = callDefault(request);        
        this.orderGraph = this.response.getOrderGraph();
        this.order = this.orderGraph.getOrder();
        
    }

    /**
     * @description Update order record with any custom values
     * 
     */
    @TestVisible
    private void updateOrderRecord() {
        
        //Update payment method on order record
        if(String.isNotBlank(this.cart?.getPaymentMethodId()) && String.isNotBlank(this.cart?.getPaymentGroupId())) {

            this.order.Payment_Method__c = SIB_Constants.ORDER_PM_CREDITCARD;
            this.order.Payment_Status__c = checkForPaymentStatus(this.cart?.getPaymentMethodId(), this.cart?.getPaymentGroupId());
        } else {

            this.order.Payment_Method__c = (this.cart?.getGrandTotalAmount() == 0.0 || this.cart?.getTotalAmountAfterAllAdjustments() == 0.0) ? SIB_Constants.PARAM_CHARGE_NOCHARGE : SIB_Constants.ORDER_PM_INVOICE;
            this.order.Payment_Status__c = (this.order?.IsWaitlisted__c) ? SIB_Constants.PARAM_CHARGE_AUTHORIZED : SIB_Constants.PARAM_CHARGE_CHARGED;
        }
        
        this.order.BillToContactId = SIB_UserSelector.getContactIdForUserId(UserInfo.getUserId());
        if(String.isNotBlank((String) this.cart?.getCustomField(SIB_Constants.PARAM_ORGINALCARDTYPE_FIELD_NAME))) {

            this.order.Original_Card_Type__c = (String) this.cart?.getCustomField(SIB_Constants.PARAM_ORGINALCARDTYPE_FIELD_NAME);
        }
        if(getCollevaItemsInOrder(this.orderGraph.getOrderItems()))      //get any colleva products in order);)
        {
            System.debug('isCollevaProductAvailable : ');
            this.order.Colleva_Order__c = true;
        }
        List<CartDeliveryGroup> cartDeliveryGroupsObject = [SELECT Id,DeliverToStreet, DeliverToCity,DeliverToState,
                                                                DeliverToCountry, DeliverToPostalCode FROM CartDeliveryGroup
                                                                WHERE CartId =:this.cart.getId()];
        if(cartDeliveryGroupsObject!=null && cartDeliveryGroupsObject.size()>0)
        {
            this.order.BillingStreet = cartDeliveryGroupsObject[0].DeliverToStreet;
            this.order.BillingState = cartDeliveryGroupsObject[0].DeliverToState;
            this.order.BillingCountry = cartDeliveryGroupsObject[0].DeliverToCountry;
            this.order.BillingPostalCode = cartDeliveryGroupsObject[0].DeliverToPostalCode;
        }
    }

    /**
     * @description Method iterates the order items and creates new order item if order item product exists on orderItemProdIdToBundleItemMap
     */
    @TestVisible
    private void handleBundledOrderItemCreation(List<OrderItem> orderItems) {

        Map<String, List<Bundle_Item__c>> orderItemProdIdToBundleItemMap = this.dataWrapper?.orderItemProdIdToBundleItemMap;
        List<OrderItem> newOrderItems = new List<OrderItem>();
        System.debug('orderItemProdIdToBundleItemMap:: '+ JSON.serializePretty(orderItemProdIdToBundleItemMap));

        //iterate current order items and add newly created order item to the list of new order items
        for(OrderItem orderItem : orderItems) {
            
            Set<String> parentChildIdSet = new Set<String>();
            parentChildIdSet.add(orderItem?.Product2Id); //Avoid parent being added again
            if( orderItemProdIdToBundleItemMap.containsKey(orderItem?.Product2Id) 
                && null != orderItemProdIdToBundleItemMap.get(orderItem?.Product2Id)) {

                    List<Bundle_Item__c> bundleItems = orderItemProdIdToBundleItemMap.get(orderItem?.Product2Id);
                    for(Bundle_Item__c item : bundleItems) {
                        if(null != parentChildIdSet && !parentChildIdSet.contains( item?.Bundle_Item__c)) { //check if child for current bundle has been added
                            OrderItem newOrderItem = new OrderItem();
                            newOrderItem.Product2Id = item?.Bundle_Item__c;
                            newOrderItem.Type = SIB_SetupConstants.ORDER_ITEM_TYPE_DELIVERY_CHARGE;
                            newOrderItem.ListPrice = 0.0;
                            newOrderItem.OrderDeliveryGroupId = orderItem?.OrderDeliveryGroupId;
                            newOrderItem.OrderId = orderItem?.OrderId;
                            newOrderItem.Quantity = item?.Quantity__c * orderItem?.Quantity; //To handle multiple quantity in bundle
                            newOrderItem.TotalLineAmount = 0.0;
                            newOrderItem.UnitPrice = 0.0;
                            parentChildIdSet.add(item?.Bundle_Item__c); // add the child item to be skipped next time
                            newOrderItems.add(newOrderItem);
                        }
                    }
            }
        }

        //Order Graph cannot be modified when orderItems are being iterated so iterate the new list of order items and add to order graph
        for( OrderItem newOrderItem : newOrderItems) {

            this.orderGraph.addNode(newOrderItem);//update the order graph with new order item data 
        }
    }


    /**
     * @description Method to fetch bundle items based on order item products, Builds a order Item product id to bundle item map
     */
    @TestVisible
    private void getBundleItemsList() {
        
        List<Id> childBundleList = new List<Id>();
        
        if(null != this.dataWrapper && null != this.dataWrapper?.orderItemProductIdList 
            && !this.dataWrapper?.orderItemProductIdList.isEmpty() ) {
            //First Level querying 
            List<Bundle_Item__c> bundleItemsList = SIB_BundleItemSelector.getBundleItemsByProductIds(this.dataWrapper.orderItemProductIdList); 
            
            if(null != bundleItemsList && !bundleItemsList.isEmpty()) { 
                this.isBundleProductAvailable = true;
                for(Bundle_Item__c bundleItem : bundleItemsList) {
                    childBundleList.add(bundleItem?.Bundle_Item__c);
                }  
                
                if(childBundleList != null && !childBundleList.isEmpty()) {
                    //Second Level querying - Get bundle of bundle
                    List<Bundle_Item__c> childBundleItemsList = SIB_BundleItemSelector.getBundleItemsByProductIds(childBundleList);
                    if(childBundleItemsList != null && !childBundleItemsList.isEmpty()) {
                        for(Bundle_Item__c bundleItem : childBundleItemsList) {

                            bundleItemsList.add( bundleItem);
                        }
                    } 
                }

                //prepare bundle items for order products
                this.dataWrapper.orderItemProdIdToBundleItemMap = prepareItemProdIdToBundlesMap(bundleItemsList);
            }
        }
    }

    @TestVisible
    private Map<String, List<Bundle_Item__c>> prepareItemProdIdToBundlesMap(List<Bundle_Item__c> bundleItemsList) {

        //prepare map of all bundle items retrieved
        Map<String, List<Bundle_Item__c>> bundleParentIdToItemList = new Map<String, List<Bundle_Item__c>>();
        for(Bundle_Item__c bundleItem : bundleItemsList) {

            if(null != bundleParentIdToItemList) {
                
                if(!bundleParentIdToItemList.containsKey(bundleItem?.Bundle_Parent_Item__c)) {

                    List<Bundle_Item__c> newBundleItemsList = new List<Bundle_Item__c>();
                    newBundleItemsList.add(bundleItem);
                    bundleParentIdToItemList.put(bundleItem?.Bundle_Parent_Item__c, newBundleItemsList);
                } else {

                    List<Bundle_Item__c> currentBundleItemsList = (null != bundleParentIdToItemList.get(bundleItem?.Bundle_Parent_Item__c ))? bundleParentIdToItemList.get(bundleItem?.Bundle_Parent_Item__c) : new List<Bundle_Item__c>();
                    if(null != currentBundleItemsList) currentBundleItemsList.add(bundleItem);
                    bundleParentIdToItemList.put(bundleItem?.Bundle_Parent_Item__c, currentBundleItemsList);
                }
            }
        }

        //iterate through order item and build bundleItems list for each order item
        for(OrderItem orderItemRecord : this.orderGraph.getOrderItems()) {

            List<Bundle_Item__c> bundleItemsForOrderItem  = new List<Bundle_Item__c>();
            List<Bundle_Item__c> childBundleItemForOrderItem = new List<Bundle_Item__c>();
            if(null != bundleParentIdToItemList && !bundleParentIdToItemList.isEmpty() && bundleParentIdToItemList.containsKey(orderItemRecord?.Product2Id)) {

                List<Bundle_Item__c> currentBundleItem = bundleParentIdToItemList.get(orderItemRecord?.Product2Id);
                bundleItemsForOrderItem.addAll(currentBundleItem);

                for(Bundle_Item__c bundleItem : bundleItemsForOrderItem) {

                    //check for child bundle item for current bundle item 
                    if(bundleParentIdToItemList.containsKey(bundleItem?.Bundle_Item__c)) {

                        childBundleItemForOrderItem.addAll(bundleParentIdToItemList.get(bundleItem?.Bundle_Item__c));
                    } 
                }
                
                if(null != childBundleItemForOrderItem && !childBundleItemForOrderItem.isEmpty()) bundleItemsForOrderItem.addAll(childBundleItemForOrderItem);

                this.dataWrapper.orderItemProdIdToBundleItemMap.put(orderItemRecord?.Product2Id, bundleItemsForOrderItem);
            } 
        }

        return this.dataWrapper.orderItemProdIdToBundleItemMap;
        
    }

    /**
     * @description Method to instantiate datawrapper and create order item product id list
     */
    @TestVisible 
    private SIB_OrderDetailsWrapper getWrapperDataFromOrderItem(List<OrderItem> orderItems) {

        this.dataWrapper = new SIB_OrderDetailsWrapper();

        for(OrderItem orderItemRecord : orderItems) {
            this.dataWrapper?.orderItemProductIdList.add(orderItemRecord?.Product2Id); //add list of product id's to check for bundle product
        }

        return this.dataWrapper;
    }

     /**
     * @description Method to instantiate datawrapper and create order item product id list
     */
    @TestVisible 
    private Boolean getCollevaItemsInOrder(List<OrderItem> orderItems) {

        Boolean isCollevaProductAdded = false;
        System.debug('isCollevaProductAvailable : size '+ orderItems.size());
        System.debug('isCollevaProductAvailable : size '+ orderItems);
        System.debug('isCollevaProductAvailable : size '+ orderItems.get(0));
        System.debug('isCollevaProductAvailable : size '+ this.order);
        System.debug('isCollevaProductAvailable : orderId '+ orderItems.get(0).OrderId);
        Set<String> productIds = new Set<String>();
        for(OrderItem orderItemObject : orderItems)
        {
            productIds.add(orderItemObject.Product2Id);
        }
        List<Product2> lstProducts = [SELECT Id,Colleva_Product__c FROM Product2 WHERE Id IN : productIds AND Colleva_Product__c = TRUE];
        if(lstProducts!=null && lstProducts.size()>0)
        {
            isCollevaProductAdded = true;
        }
        System.debug('isCollevaProductAvailable : '+ isCollevaProductAdded);
        return isCollevaProductAdded;
    }

    @TestVisible
    private CartExtension.CreateOrderResponse callDefault(CartExtension.CreateOrderRequest request) {
        return super.createOrder(request);        
    }

    @TestVisible
    private String checkForPaymentStatus(String paymentMethodId, String paymentGroupId){
        String paymentStatus = SIB_Constants.PARAM_CHARGE_AUTHORIZED;

        List<PaymentAuthorization> paymentAuthRecords = [SELECT Id, TotalAuthReversalAmount, TotalPaymentCaptureAmount, Amount FROM PaymentAuthorization WHERE PaymentMethodId = :paymentMethodId AND PaymentGroupId = :paymentGroupId  LIMIT 1];

        if(null != paymentAuthRecords && !paymentAuthRecords.isEmpty()) {

            PaymentAuthorization paymentAuthRecord = paymentAuthRecords[0];
            paymentStatus = paymentAuthRecord?.TotalAuthReversalAmount == 0 && paymentAuthRecord?.TotalPaymentCaptureAmount > 0 ? SIB_Constants.PARAM_CHARGE_CHARGED : paymentStatus;
        }

        return paymentStatus;
    }

    /**
     * Wrapper class to handle instance data
     */
    private class SIB_OrderDetailsWrapper{
        
        public Map<String, List<Bundle_Item__c>> orderItemProdIdToBundleItemMap {get;set;}
        public List<Id> orderItemProductIdList {get;set;}

        public SIB_OrderDetailsWrapper() {
            this.orderItemProdIdToBundleItemMap = new Map<String, List<Bundle_Item__c>>();
            this.orderItemProductIdList = new List<Id>();
        } 
    }

}