/**
 * @description       : 
 * @author            : sthakur@rafter.one
 * @group             : 
 * @last modified on  : 04-21-2024
 * @last modified by  : sthakur@rafter.one
**/
public class SIB_OrderSummaryResponse {

    @InvocableVariable
    public OrderSummary orderSummary;

    public SIB_OrderSummaryResponse() {

    }

    public SIB_OrderSummaryResponse(OrderSummary os) {
        orderSummary = os;
    }
}