@isTest(SeeAllData=true)
public with sharing class Saltbox_OrderSummaryProductsServiceTest {
    public static String accountId = [SELECT Id, AccountId FROM OrderSummary ORDER BY CreatedDate DESC NULLS LAST LIMIT 1].AccountId;
    @isTest
    static void shouldReturnOrderDeliveryGroupSummaries() {
        WebStore store = [
            SELECT Name, Id
            FROM WebStore
            LIMIT 1
        ];
        Account account = [SELECT Id FROM Account WHERE Id = :accountId];
        OrderSummary orderSummary = [
            SELECT Id
            FROM OrderSummary
            WHERE AccountId = :account.Id
            LIMIT 1
        ];
        ConnectApi.OrderDeliveryGroupSummaryCollection odgs = new ConnectApi.OrderDeliveryGroupSummaryCollection();
        Test.startTest();
        odgs = Saltbox_OrderSummaryProductsService.getOrderDeliveryGroupSummaries(
            store.Id,
            account.Id,
            orderSummary.Id
        );
        Test.stopTest();
        System.assertNotEquals(null, odgs);
    }
    @isTest
    static void shouldReturnOrderItemSummaries() {
        WebStore store = [
            SELECT Name, Id
            FROM WebStore
            LIMIT 1
        ];
        Account account = [SELECT Id FROM Account WHERE Id = :accountId];
        OrderSummary orderSummary = [
            SELECT Id
            FROM OrderSummary
            WHERE AccountId = :account.Id
            LIMIT 1
        ];

        OrderDeliveryGroupSummary odgs = [
            SELECT Id
            FROM OrderDeliveryGroupSummary
            WHERE
                OrderSummaryId = :orderSummary.Id
                AND OrderDeliveryMethod.Carrier != 'Digital'
                AND OrderDeliveryMethod.Carrier != 'No Shipping'
            LIMIT 1
        ];
        List<OrderItemSummary> oisList = new List<OrderItemSummary>();
        for (OrderItemSummary ois : [
            SELECT
                Id,
                Product2Id
            FROM OrderItemSummary
            WHERE OrderDeliveryGroupSummaryId = :odgs.Id
        ]) {
            oisList.add(ois);
        }
        update oisList;
        ConnectApi.OrderItemSummaryCollection oisc = new ConnectApi.OrderItemSummaryCollection();
        Test.startTest();
        oisc = Saltbox_OrderSummaryProductsService.getOrderItemSummaries(
            store.Id,
            account.Id,
            orderSummary.Id,
            odgs.Id
        );
        Test.stopTest();
        System.assertNotEquals(null, oisc);
    }
}