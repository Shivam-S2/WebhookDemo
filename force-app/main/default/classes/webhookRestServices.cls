@RestResource(urlMapping='/api/webhooks/incoming/pushDetails/*')
global with sharing class webhookRestServices {
    public webhookRestServices() {

    }

    @HttpPost
    global static void handleRequest(){
        //Request
        RestRequest request = RestContext.request;

        //getBody
        Blob requestBody = request.requestBody;

        //response
        RestResponse response = RestContext.response;
    }
}
