/**
 * Created by junaidmohammed on 10/4/24.
 */

@RestResource(UrlMapping='/b2b/v1/cart')
global without sharing class SIB_FetchMiniCartService {

    @HttpPost
    global static void fetchMiniCartDetail(SIB_MiniCartVO.Request miniCartRequest) {
        RestResponse response = RestContext.response;
        try {
            SIB_MiniCartVO.Response miniCartDetailResponse = fetchCartDetails(miniCartRequest);
            if(miniCartDetailResponse!=null)
            {
                response.responseBody = Blob.valueOf(JSON.serialize(miniCartDetailResponse ,true) );
                response.addHeader('Content-Type', 'application/json');
            }
        } catch (Exception expObject) {
            response.statusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(expObject.getMessage()));
        }
    }

    //'fd1e3949-2afc-4a7b-b4c0-b0bc204e9e82'
    global static SIB_MiniCartVO.Response fetchCartDetails(SIB_MiniCartVO.Request request)
    {
        Boolean success = false;
        String message = null;
        SIB_MiniCartVO.Response miniCartResponse = new SIB_MiniCartVO.Response();
        if(request!=null && String.isNotBlank(request.identifier))
        {
            List<User> lstUsers = [SELECT Id, Account.Name FROM User
                                    WHERE Contact.Strivacity_Identifier__c=:request.identifier WITH SYSTEM_MODE];
            if(lstUsers!=null && lstUsers.size()>0)
            {
                List<WebCart> lstWebCarts = [SELECT Id,TotalProductCount, Account.Name FROM WebCart WHERE
                                                Status IN ('Active', 'Checkout') AND
                                                OwnerId =: lstUsers[0].Id WITH SYSTEM_MODE];
                if(lstWebCarts!=null && lstWebCarts.size()>0)
                {
                    WebCart webCartObject = lstWebCarts[0];
                    miniCartResponse.totalProductCount = webCartObject.TotalProductCount!=null ? Integer.valueOf(webCartObject.TotalProductCount) : 0 ;
                }else
                {
                    message = 'No Cart Found';
                }
                miniCartResponse.Name = lstUsers[0].Account.Name;
            }else
            {
                message = 'No User Found';
            }
            success = true;
        }
        miniCartResponse.success = success;
        miniCartResponse.message = message;
        return miniCartResponse;
    }

}