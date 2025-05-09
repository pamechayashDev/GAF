public without sharing class  UPPNotificationPreferenceSelector extends fflib_SObjectSelector {
    
    // Specify the SObject Type
    public  Schema.SObjectType getSObjectType() {
        return UPP_Notifications_Preferences__c.SObjectType;
    }
    
    // Specify the Fields to Query
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            UPP_Notifications_Preferences__c.Id,
            UPP_Notifications_Preferences__c.Preferences__c,
            UPP_Notifications_Preferences__c.Deliver_Message_By_Email__c,
            UPP_Notifications_Preferences__c.Records_Per_Page__c,
            UPP_Notifications_Preferences__c.User__c
        };
    }
    
    // Method to Query User Preferences
    public List<UPP_Notifications_Preferences__c> selectPreferencesByUser(List<Id> userIds) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('User__c IN :userIds');
        queryFactory.setLimit(1);
        system.debug(queryFactory.toSOQL());
        return (List<UPP_Notifications_Preferences__c>) Database.query(queryFactory.toSOQL());
    }
}