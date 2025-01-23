/**
 * @description       : Test class for SIB_OrderVO
 * @author            : Jeetendranath Jakkamsetti
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Jeetendranath Jakkamsetti
**/
@isTest
public class SIB_OrderVOTest {
    
    @isTest
    public static void testSIBOrderVO() {
        SIB_OrderVO.SIB_OrderItemsVO orderItem1 = new SIB_OrderVO.SIB_OrderItemsVO();
        orderItem1.Id = 'TestOrder123';
        orderItem1.Product2Id = 'TestProduct';
        orderItem1.Name = 'Product Name 1';
        orderItem1.ProductImage = 'https://example.com/product1.jpg';
        orderItem1.IsSubscriptionProduct = false;
        orderItem1.SKU = 'SKU123';
        orderItem1.Quantity = 2;
        orderItem1.ListPrice = 100.00;
        orderItem1.UnitPrice = 90.00;
        orderItem1.TotalPrice = 180.00;
        orderItem1.AmountSaved = 20.00;
        orderItem1.productSlugURL = '/product1-url';


        SIB_OrderVO order = new SIB_OrderVO();
        order.Id = 'ORD000123';
        order.OrderNumber = 'ORD-10001';
        order.OrderedDate = DateTime.now();
        order.BillingStreet = '123 Billing St';
        order.BillingCity = 'Billing City';
        order.BillingStateCode = 'BC';
        order.BillingPostalCode = '12345';
        order.BillingCountryCode = 'US';
        order.BillingPhoneNumber = '123-456-7890';
        order.BillingEmailAddress = 'billing@example.com';
        order.BillingName = 'John Doe';
        order.PoNumber = 'PO123456';
        order.CurrencyIsoCode = 'USD';
        order.ShippingAmount = 10.00;
        order.ShippingName = 'John Doe';
        order.ShippingStreet = '456 Shipping St';
        order.ShippingCity = 'Shipping City';
        order.ShippingStateCode = 'SC';
        order.ShippingPostalCode = '67890';
        order.ShippingCountryCode = 'US';
        order.ShippingMethod = 'Standard';
        order.clientName = 'ACME Corporation';
        order.status = 'Completed';
        order.isPublicCourseExist = true;
        order.GrandTotalAmount = 190.00;
        order.TotalTaxAmount = 15.00;
        order.TotalProductAmount = 180.00;
        order.OrderAdjustment = -5.00;
        order.paymentMethod = 'Credit Card';
        order.paymentSummaryMethodName = 'Visa **** 1234';
        order.orderItems = new List<SIB_OrderVO.SIB_OrderItemsVO>{orderItem1};

        System.assertEquals('ORD000123', order.Id,'Passed');
        
    }
}