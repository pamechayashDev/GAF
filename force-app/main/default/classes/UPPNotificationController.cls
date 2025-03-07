public with sharing class UPPNotificationController {
    @AuraEnabled
    public static List<UPP_Notification__c> getUserNotifications(  
    Date dateFrom,
    Date dateTo,
    Boolean showArchived,
    String calledFrom,
    String messageStatus,
    String messageType,
    String preferencesString
    ) {

        Id currentUserId = UserInfo.getUserId();
       String recType ='Active';
       String baseQuery = showArchived? 'SELECT Id, Business_Area__c,Is_Read__c, Message_Type__c,Subject__c, Sent__c, Message__c, User__c ,User__r.Name FROM UPP_Notification__c WHERE User__c = :currentUserId' : 'SELECT Id, Business_Area__c,Is_Read__c, Message_Type__c,Subject__c, Sent__c, Message__c, User__c ,User__r.Name FROM UPP_Notification__c WHERE RecordType.Name = :recType And User__c = :currentUserId';
 
        List<String> conditions = new List<String>();
        system.debug('preferencesString'+preferencesString);
       if(preferencesString!=null){

         List<String> preferencesList = preferencesString.split(';');
         system.debug('preferencesList---'+preferencesList);
        conditions.add('Message_Type__c IN :preferencesList');
       }
        if(messageStatus!='None'){
            Boolean isRead = messageStatus=='Unread Only'?false:true;
            conditions.add('Is_Read__c = :isRead');
         }

            if (dateFrom != null) {
                conditions.add('Sent__c >= :dateFrom');
            }
            if (dateTo != null) {
                conditions.add('Sent__c <= :dateTo');
            }
            if(messageType!='None'){
                conditions.add('Message_Type__c = :messageType');
            }
        
        if (!conditions.isEmpty()) {
            baseQuery += ' AND ' + String.join(conditions, ' AND ');
        }
        return Database.query(baseQuery);
    }

  @AuraEnabled
   public static String getUppNotificationPreferences(){

        List<UPP_Notifications_Preferences__c>  preferencesList = [Select Id, Preferences__c from UPP_Notifications_Preferences__c where User__c=:UserInfo.getUserId()];
        return preferencesList[0].Preferences__c;
       }

       @AuraEnabled
      public static void saveOrUpdatePreferences(String preferences) {
        try {
            List<UPP_Notifications_Preferences__c>  preferencesList =[Select Id, Preferences__c from UPP_Notifications_Preferences__c where User__c=:UserInfo.getUserId()];
            if(preferencesList.isEmpty()){
                UPP_Notifications_Preferences__c preference = new UPP_Notifications_Preferences__c(Preferences__c = preferences,User__c= UserInfo.getUserId());
                insert preference;
            }
            else {
                preferencesList[0].Preferences__c = preferences;
                update preferencesList[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}