/**
 * @description : A controller class for the Order Summary Products LWC.
 * @created Date : 30/12/2022
 * @Author : Rodrigo Hernandez
 * @LastModified : 30/12/2022
 */
public with sharing class Saltbox_OrderSummaryProductsService {
    /*
     * @description : This method is for getting all the Order delivery group summaries
     * @param CommunityId: The community Id
     * @param effectiveAccountId: The effective account Id
     * @param orderSummaryId: The order summary Id
     * @created Date : 30/12/2022
     * @Return : A collection of all the order delivery group summaries for the order summary
     */
    @AuraEnabled
    public static ConnectApi.OrderDeliveryGroupSummaryCollection getOrderDeliveryGroupSummaries(
        String communityId,
        String effectiveAccountId,
        String orderSummaryId
    ) {
        String webstoreId = returnWebstoreId(communityId);
        List<String> fields = new List<String>();
        fields.add('OrderDeliveryGroupSummary.DeliverToStreet');
        fields.add('OrderDeliveryGroupSummary.DeliverToCity');
        fields.add('OrderDeliveryGroupSummary.DeliverToState');
        fields.add('OrderDeliveryGroupSummary.DeliverToPostalCode');
        fields.add('OrderDeliveryGroupSummary.DeliverToCountry');
        fields.add('OrderDeliveryGroupSummary.TotalAmount');
        fields.add('OrderDeliveryMethod.Carrier');
        ConnectApi.OrderDeliveryGroupSummaryCollection odgs = ConnectApi.CommerceBuyerExperience.getOrderDeliveryGroupSummaries(
            webstoreId,
            effectiveAccountId,
            orderSummaryId,
            fields
        );
        return odgs;
    }

    /*
     * @description : This method is for getting all the Order item summaries
     * @param CommunityId: The community Id
     * @param effectiveAccountId: The effective account Id
     * @param orderSummaryId: The order summary Id
     * @param orderDeliveryGroupSummaryId: The order delivery group summary Id
     * @created Date : 30/12/2022
     * @Return : A collection of all the order item summaries for the order delivery group summary
     */
    @AuraEnabled
    public static ConnectApi.OrderItemSummaryCollection getOrderItemSummaries(
        String communityId,
        String effectiveAccountId,
        String orderSummaryId,
        String orderDeliveryGroupSummaryId
    ) {
        String webstoreId = returnWebstoreId(communityId);
        List<String> fields = new List<String>();
        fields.add('OrderItemSummary.Name');
        fields.add('OrderItemSummary.Quantity');
        fields.add('OrderItemSummary.UnitPrice');
        fields.add('OrderItemSummary.StockKeepingUnit');
        fields.add('Product2.Name');
        fields.add('OrderItemSummary.TotalAmtWithTax');
        fields.add('OrderItemSummary.Product2Id');

        ConnectApi.OrderItemSummaryCollection oisc = ConnectApi.CommerceBuyerExperience.getOrderItemSummaries(
            webstoreId,
            effectiveAccountId,
            orderSummaryId,
            orderDeliveryGroupSummaryId,
            fields
        );


        return oisc;
    }

    /*
     * @description : This method is for getting the webstore Id from the community Id
     * @param CommunityId: The community Id
     * @created Date : 30/12/2022
     * @Return : The webstore Id
     */
    private static String returnWebstoreId(String communityId) {
        if (Test.isRunningTest()) {
            communityId = System.label.Saltbox_Network_ID;
        } else {
            communityId = Network.getNetworkId();
        }
        String webstoreId = Saltbox_B2BUtils.resolveCommunityIdToWebstoreId(
            communityId
        );
        return webstoreId;
    }
}