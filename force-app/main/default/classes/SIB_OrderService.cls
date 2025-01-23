/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 08-13-2024
 * @last modified by  : Gaurav Setia
**/
public with sharing class SIB_OrderService {
    
    private static final String CONFIG_TYPE = 'ORDER DETAILS';

    public static Map<String,Object> getOrderConfiguration(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';
        mapParams.put('configurationType', CONFIG_TYPE);
        SIB_ConfigurationService.getConfigurationJSON(mapParams);
        if(mapParams.containsKey('configJSON')) {
            SIB_OrderConfiguration orderConfig = SIB_OrderConfiguration.parse((String)mapParams.get('configJSON'));
            mapParams.put('orderConfig', orderConfig);
            isSuccess = true;
        }else{
            message = 'Order Config JSON not found.';
        }
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static Map<String,Object> getOrderDetails(Map<String,Object> mapParams){
        Boolean isSuccess = false;
        String message = '';

        if((mapParams != null) && ((mapParams.containsKey('recordId') && mapParams.get('recordId') != null) || 
            (mapParams.containsKey('orderNumber') && mapParams.get('orderNumber') != null))) {
            List<OrderSummary> ordSumList = new List<OrderSummary>();
            List<Order> ordList = new List<Order>();
            mapParams.put('configurationType', CONFIG_TYPE);
            SIB_ConfigurationService.getConfigurationJSON(mapParams);
            if(mapParams.containsKey('configJSON')) {
                SIB_OrderConfiguration orderConfig = SIB_OrderConfiguration.parse((String)mapParams.get('configJSON'));
                mapParams.put('orderConfig', orderConfig);
                if(orderConfig.objectApiName == 'OrderSummary') {
                    if(mapParams.containsKey('recordId')) {
                        String recordId = (String)mapParams.get('recordId');
                        ordSumList = (List<OrderSummary>)SIB_OrderSummarySelector.getOrderSummaryByIds(new List<Id>{recordId});
        
                    }else if(mapParams.containsKey('orderNumber')){
                        String orderNumber = (String)mapParams.get('orderNumber');
                        ordSumList = (List<OrderSummary>)SIB_OrderSummarySelector.getOrderSummaryByOrderReferenceNumbers(new List<String>{orderNumber});
                    }
                    if(ordSumList != null && ordSumList.size() > 0) {
                        isSuccess = true;
                        OrderSummary currOrder = ordSumList[0];
                        SIB_OrderVO orderWrapper = getOrderSummaryData(currOrder);
                        mapParams.put('orderWrapper', orderWrapper);
                        if(String.isNotBlank(ordSumList[0].CartId__c)) {
                            
                        }
                    }else {
                        isSuccess = false;
                        message = 'No Order Found.';
                    }    
                } else if(orderConfig.objectApiName == 'Order') {
                    if(mapParams.containsKey('recordId')) {
                        String recordId = (String)mapParams.get('recordId');
                        ordList = (List<Order>)SIB_OrderSelector.getOrderByIds(new List<Id>{recordId});
        
                    }else if(mapParams.containsKey('orderNumber')){
                        String orderNumber = (String)mapParams.get('orderNumber');
                        ordList = (List<Order>)SIB_OrderSelector.getOrderByOrderNumbers(new List<String>{orderNumber});
                    }
                    if(ordList != null && ordList.size() > 0) {
                        isSuccess = true;
                        Order currOrder = ordList[0];
                        SIB_OrderVO orderWrapper = getOrderData(currOrder);
                        mapParams.put('orderWrapper', orderWrapper);
                        if(String.isNotBlank(ordList[0].CartId__c)) {
                            
                        }
                    }else {
                        isSuccess = false;
                        message = 'No Order Found.';
                    }
                }
            } else{
                message = 'Order Config JSON not found.';
            }
        }
        
        mapParams.put('isSuccess', isSuccess);
        mapParams.put('message', message);
        return mapParams;
    }

    public static SIB_OrderVO getOrderSummaryData(OrderSummary currOrder) {
        SIB_OrderVO orderWrapper = new SIB_OrderVO();
        orderWrapper.Id = currOrder.Id;
        orderWrapper.OrderNumber = currOrder.OriginalOrder.OrderNumber;
        orderWrapper.OrderedDate = currOrder.OrderedDate;
        orderWrapper.BillingStreet = currOrder.BillingStreet;
        orderWrapper.BillingCity = currOrder.BillingCity;
        orderWrapper.BillingStateCode = currOrder.BillingStateCode;
        orderWrapper.BillingPostalCode = currOrder.BillingPostalCode;
        orderWrapper.BillingCountryCode = currOrder.BillingCountryCode;
        orderWrapper.BillingPhoneNumber = currOrder.BillingPhoneNumber;
        orderWrapper.BillingEmailAddress = currOrder.Owner.Email;
        orderWrapper.BillingName = currOrder.Owner.Name;
        orderWrapper.clientName = currOrder.Account.Name;
        orderWrapper.status = currOrder.Status;
        orderWrapper.PoNumber = currOrder.PoNumber;
        orderWrapper.paymentMethod = currOrder.Payment_Method__c;
        orderWrapper.isPublicCourseExist = false;
        orderWrapper.ShippingAmount = currOrder.TotalAdjustedDeliveryAmount;
        orderWrapper.CurrencyIsoCode = currOrder.CurrencyIsoCode;
        orderWrapper.GrandTotalAmount = currOrder.GrandTotalAmount;
        orderWrapper.TotalTaxAmount = currOrder.TotalTaxAmount;
        orderWrapper.TotalProductAmount = currOrder.TotalProductAmount;
        if(currOrder.TotalProductAmount - currOrder.TotalAmount > 0) {
            orderWrapper.OrderAdjustment = currOrder.TotalProductAmount - currOrder.TotalAmount;
        }

        //order items
        List<OrderItemSummary> currOrderItems = currOrder.OrderItemSummaries;
        if(currOrderItems != null && currOrderItems.size() > 0) {
            List<String> productIds = new List<String>();
            List<SIB_OrderVO.SIB_OrderItemsVO> orderItems = new List<SIB_OrderVO.SIB_OrderItemsVO>();
            for(OrderItemSummary currOrderItem : currOrderItems) {
                SIB_OrderVO.SIB_OrderItemsVO orderItemWrapper = new SIB_OrderVO.SIB_OrderItemsVO();
                orderItemWrapper.Id = currOrderItem.Id;
                orderItemWrapper.Product2Id = currOrderItem.Product2Id;
                orderItemWrapper.Name = currOrderItem.Product2.Name;
                orderItemWrapper.SKU = currOrderItem.Product2.StockKeepingUnit;
                orderItemWrapper.productSlugURL = currOrderItem.Product2.SIB_SlugUrl__c;
                orderItemWrapper.Quantity = currOrderItem.Quantity;
                orderItemWrapper.UnitPrice = currOrderItem.UnitPrice;
                if(currOrderItem.UnitPrice != currOrderItem.ListPrice) {
                    orderItemWrapper.ListPrice = currOrderItem.ListPrice;
                }
                orderItemWrapper.TotalPrice = currOrderItem.TotalPrice;

                Decimal totalListPrice = currOrderItem.ListPrice * currOrderItem.Quantity;
                if(totalListPrice != currOrderItem.TotalPrice) {
                    orderItemWrapper.AmountSaved = totalListPrice - currOrderItem.TotalPrice;
                    orderItemWrapper.ListPrice = totalListPrice;
                }

                if(currOrderItem.Product2.Product_Group__c != null && currOrderItem.Product2.Product_Group__c == SIB_Constants.PRODUCT_GROUP_PUBLIC_COURSE) {
                    orderWrapper.isPublicCourseExist = true;
                }
                productIds.add(currOrderItem.Product2Id);
                orderItems.add(orderItemWrapper);
            }
            orderWrapper.orderItems = orderItems;
        }
        
        //shipping details
        List<OrderDeliveryGroupSummary> currDeliveryGroups = currOrder.OrderDeliveryGroupSummaries;
        if(currDeliveryGroups != null && currDeliveryGroups.size() > 0) {
            OrderDeliveryGroupSummary currDeliveryGroup = currDeliveryGroups[0];
            orderWrapper.ShippingName = currDeliveryGroup.DeliverToName;
            orderWrapper.ShippingStreet = currDeliveryGroup.DeliverToStreet;
            orderWrapper.ShippingCity = currDeliveryGroup.DeliverToCity;
            orderWrapper.ShippingStateCode = currDeliveryGroup.DeliverToStateCode;
            orderWrapper.ShippingPostalCode = currDeliveryGroup.DeliverToPostalCode;
            orderWrapper.ShippingCountryCode = currDeliveryGroup.DeliverToCountryCode;
            orderWrapper.ShippingMethod = currDeliveryGroup.OrderDeliveryMethod.Name;
        }

        //shipping details
        List<OrderPaymentSummary> currPaymentDetails = currOrder.OrderPaymentSummaries;
        if(currPaymentDetails != null && currPaymentDetails.size() > 0) {
            OrderPaymentSummary currPaymentDetail = currPaymentDetails[0];
            orderWrapper.paymentSummaryMethodName = currPaymentDetail.Method;
        }

        return orderWrapper;
    }

    public static SIB_OrderVO getOrderData(Order currOrder) {
        SIB_OrderVO orderWrapper = new SIB_OrderVO();
        orderWrapper.Id = currOrder.Id;
        orderWrapper.OrderNumber = currOrder.OrderNumber;
        orderWrapper.OrderedDate = currOrder.OrderedDate;
        orderWrapper.BillingStreet = currOrder.Account.BillingStreet;
        orderWrapper.BillingCity = currOrder.Account.BillingCity;
        orderWrapper.BillingStateCode = currOrder.Account.BillingStateCode;
        orderWrapper.BillingPostalCode = currOrder.Account.BillingPostalCode;
        orderWrapper.BillingCountryCode = currOrder.Account.BillingCountryCode;
        orderWrapper.BillingPhoneNumber = currOrder.BillingPhoneNumber;
        orderWrapper.BillingEmailAddress = currOrder.Owner.Email;
        orderWrapper.BillingName = currOrder.Owner.Name;
        orderWrapper.PoNumber = currOrder.PoNumber;
        orderWrapper.ShippingAmount = currOrder.TotalAdjustedDeliveryAmount;
        orderWrapper.CurrencyIsoCode = currOrder.CurrencyIsoCode;
        orderWrapper.GrandTotalAmount = currOrder.GrandTotalAmount;
        orderWrapper.TotalTaxAmount = currOrder.TotalTaxAmount;
        orderWrapper.TotalProductAmount = currOrder.TotalAdjustedProductAmount;
        /*orderWrapper.TotalProductAmount = currOrder.TotalProductAmount;
        if(currOrder.TotalProductAmount - currOrder.TotalAdjustedProductAmount > 0) {
            orderWrapper.OrderAdjustment = currOrder.TotalProductAmount - currOrder.TotalAdjustedProductAmount;
        }*/

        //order items
        List<OrderItem> currOrderItems = currOrder.OrderItems;
        if(currOrderItems != null && currOrderItems.size() > 0) {
            List<String> productIds = new List<String>();
            List<SIB_OrderVO.SIB_OrderItemsVO> orderItems = new List<SIB_OrderVO.SIB_OrderItemsVO>();
            for(OrderItem currOrderItem : currOrderItems) {
                SIB_OrderVO.SIB_OrderItemsVO orderItemWrapper = new SIB_OrderVO.SIB_OrderItemsVO();
                orderItemWrapper.Id = currOrderItem.Id;
                orderItemWrapper.Product2Id = currOrderItem.Product2Id;
                orderItemWrapper.Name = currOrderItem.Product2.Name;
                orderItemWrapper.SKU = currOrderItem.Product2.StockKeepingUnit;
                orderItemWrapper.Quantity = currOrderItem.Quantity;
                orderItemWrapper.UnitPrice = currOrderItem.UnitPrice;
                if(currOrderItem.UnitPrice != currOrderItem.ListPrice) {
                    orderItemWrapper.ListPrice = currOrderItem.ListPrice;
                }
                orderItemWrapper.TotalPrice = currOrderItem.TotalPrice;

                Decimal totalListPrice = currOrderItem.ListPrice * currOrderItem.Quantity;
                if(totalListPrice != currOrderItem.TotalPrice) {
                    orderItemWrapper.AmountSaved = totalListPrice - currOrderItem.TotalPrice;
                    orderItemWrapper.ListPrice = currOrderItem.ListPrice;
                }
                productIds.add(currOrderItem.Product2Id);
                orderItems.add(orderItemWrapper);
            }
            orderWrapper.orderItems = orderItems;
        }
        
        //shipping details
        List<OrderDeliveryGroup> currDeliveryGroups = currOrder.OrderDeliveryGroups;
        if(currDeliveryGroups != null && currDeliveryGroups.size() > 0) {
            OrderDeliveryGroup currDeliveryGroup = currDeliveryGroups[0];
            orderWrapper.ShippingName = currDeliveryGroup.DeliverToName;
            orderWrapper.ShippingStreet = currDeliveryGroup.DeliverToStreet;
            orderWrapper.ShippingCity = currDeliveryGroup.DeliverToCity;
            orderWrapper.ShippingStateCode = currDeliveryGroup.DeliverToStateCode;
            orderWrapper.ShippingPostalCode = currDeliveryGroup.DeliverToPostalCode;
            orderWrapper.ShippingCountryCode = currDeliveryGroup.DeliverToCountryCode;
            orderWrapper.ShippingMethod = currDeliveryGroup.OrderDeliveryMethod.Name;
        }

        return orderWrapper;
    }
}