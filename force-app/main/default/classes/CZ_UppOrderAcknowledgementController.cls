public with sharing class CZ_UppOrderAcknowledgementController {
    
    @AuraEnabled
    public static List<Upp_Order_Acknowledgement__c> fetchUppOrderAcknowledgements(Id orderId){
        List<Upp_Order_Acknowledgement__c> uppOrderAckList;
        try {
            uppOrderAckList  =[Select Id, Account__r.Name ,Sold_To_Customer_Id__r.Id,Sold_To_Customer_Id__r.Name,	File_Name__c,	Order__r.OrderNumber , Document_Link__c,User__c from Upp_Order_Acknowledgement__c Where User__c=:UserInfo.getUserId() AND Order__c=:orderId];
            return uppOrderAckList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}