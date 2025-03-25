public with sharing class UPPNotificationController {
    @AuraEnabled
    public static List<UPP_Notification__c> getUserNotifications(  
    Date dateFrom,
    Date dateTo,
    Boolean showArchived,
    String messageStatus,
    String messageType,
    String preferencesString
    ) {
        Id currentUserId = UserInfo.getUserId();
        system.debug('currentUserId'+currentUserId);
       String recType ='Active';
       String baseQuery = showArchived? 'SELECT Id, Business_Area__c,Is_Read__c, Message_Type__c,Subject__c, Sent__c, Message__c, User__c ,User__r.Name,Related_Id__c,Related_Link__c FROM UPP_Notification__c WHERE User__c = :currentUserId' : 'SELECT Id, Business_Area__c,Is_Read__c, Message_Type__c,Subject__c, Sent__c, Message__c, User__c ,User__r.Name FROM UPP_Notification__c WHERE RecordType.Name = :recType And User__c = :currentUserId';
        
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
   public static List<UPP_Notifications_Preferences__c>  getUppNotificationPreferences(){
          
        List<UPP_Notifications_Preferences__c>  preferencesList = [Select Id, Preferences__c , Deliver_Message_By_Email__c ,Records_Per_Page__c from UPP_Notifications_Preferences__c where User__c=:UserInfo.getUserId() Limit 1];
         
         system.debug('preferencesList'+preferencesList);
        
        //matching preferences with permissions
        if(preferencesList.size()!=0){
            List<String> permissions =  getUserPermissions(); 
            Set<String> permissionsSet = new Set<String>(permissions);
            List<String> filteredPreferences = new List<String>();
            if(preferencesList[0].Preferences__c!=null){
                for(String preference : preferencesList[0].Preferences__c.split(';')){
                    if(permissionsSet.contains(preference)){
                        filteredPreferences.add(preference);
                    }
                }
            }
    
            preferencesList[0].put('Preferences__c', String.join(filteredPreferences, ';'));
    
        }
        
        return preferencesList;
       }

       @AuraEnabled
      public static void saveOrUpdatePreferences(Map<String,Object> preferences) {
      String messageTypes = String.valueOf(preferences.get('messageTypes'));

     Boolean deliverMessageByEmail = true;

        try {
                 Integer recordsPerPage = Integer.valueOf(preferences.get('recordsPerPage'));
            List<UPP_Notifications_Preferences__c>  preferencesList =[Select Id, Preferences__c, Deliver_Message_By_Email__c,Records_Per_Page__c from UPP_Notifications_Preferences__c where User__c=:UserInfo.getUserId()];
            if(preferencesList.isEmpty()){
                UPP_Notifications_Preferences__c preference = new UPP_Notifications_Preferences__c(Preferences__c = messageTypes,User__c= UserInfo.getUserId(),Deliver_Message_By_Email__c=deliverMessageByEmail,Records_Per_Page__c = recordsPerPage);
                insert preference;
            }
            else {
         
                preferencesList[0].Preferences__c = messageTypes;
                preferencesList[0].Deliver_Message_By_Email__c=deliverMessageByEmail;
                preferencesList[0].Records_Per_Page__c= recordsPerPage;
                update preferencesList[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getUserPermissions(){

            List<String> resultPermissions = new List<String>();

            Map<String, String>  programPreferenceMapping =  getProgramPreferenceMappings();
         
                Id currentUserContactId = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId;

                 for(UPP_User_Permission__c permission: [SELECT Permission_Set_Api_Name__c FROM UPP_User_Permission__c WHERE Contact__r.Id = :currentUserContactId]){
                    resultPermissions.add(programPreferenceMapping.get(permission.Permission_Set_Api_Name__c));
                 }

            return resultPermissions;
     
    }

    private static Map<String, String> getProgramPreferenceMappings() {
       Map<String, String> mapping = new Map<String, String>();
        
    
 
            Map<String, UPP_Field_Mapping__mdt> metadataMap = UPP_Field_Mapping__mdt.getAll();
            
            for (UPP_Field_Mapping__mdt fieldMapping : metadataMap.values()) {
                mapping.put(fieldMapping.Program__c,fieldMapping.MasterLabel);    
            }
            return mapping;  
   

     
    }


   



    @AuraEnabled
    public static List<Map<String,String>>  updateUppNotificationRecords(List<Map<String,String>> records){
        List<UPP_Notification__c> recordsToUpdate = new List<UPP_Notification__c>();

        for (Map<String,String> rec : records) {
            UPP_Notification__c record = new UPP_Notification__c();
            record.put('Id', rec.get('Id'));
            record.put('RecordTypeId', rec.get('RecordTypeId'));
            recordsToUpdate.add(record);
        }

        try {
            update recordsToUpdate;
        } catch (DmlException e) {
            throw new AuraHandledException('Error updating records: ' + e.getMessage());
        }
     return records;

    }
    
    
    
    

}