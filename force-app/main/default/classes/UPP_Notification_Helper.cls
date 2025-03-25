public class UPP_Notification_Helper {
    
    public static void afterUppNotificationInsert(List<Upp_Notification__c> newNotifications) {
      
        // Collect the user IDs from the notifications.
        // (Assumes that each notification record contains a User__c field.)
        Set<Id> userIds = new Set<Id>();
        for (Upp_Notification__c notif : newNotifications) {
            if (notif.User__c != null) {
                userIds.add(notif.User__c);
            }
        }
        
        // If no user IDs are found, default to the current user.
        if (userIds.isEmpty()) {
            userIds.add(UserInfo.getUserId());
        }
        
        // Query the preferences for all these users at once.
        Map<Id, UPP_Notifications_Preferences__c> prefsByUser = new Map<Id, UPP_Notifications_Preferences__c>();
        for (UPP_Notifications_Preferences__c pref : [
            SELECT Id, Preferences__c, Deliver_Message_By_Email__c, User__c
            FROM UPP_Notifications_Preferences__c
            WHERE User__c IN :userIds
        ]) {
            prefsByUser.put(pref.User__c, pref);
        }
        
        // Build a list of email messages.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Upp_Notification__c notif : newNotifications) {
            // Get the user’s preferences (if any)
            UPP_Notifications_Preferences__c pref = prefsByUser.get(notif.User__c);
            if (pref != null && pref.Deliver_Message_By_Email__c) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                // For demonstration, a hard-coded email address is used.
                // In production, you would typically retrieve the email from the User record.
                email.setToAddresses(new List<String>{ 'rastovich@zesttech.net' });
                email.setSubject('New Notification Created');
                email.setPlainTextBody('New Notification Created');
                emailMessages.add(email);
            }
        }
        
        // If there are any emails to send, send them in one bulk call.
        if (!emailMessages.isEmpty()) {
            try {
               // Messaging.sendEmail(emailMessages);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }     
        
       List<Upp_Notification__c> notificationsToUpdate = new List<Upp_Notification__c>();
       //building message text
        List<Upp_Notification__c> notifications = [Select UPP_NotificationTemplate__r.Agreement_Text__c , Merge_Data__c from UPP_Notification__c where Id in :newNotifications];


        for (Upp_Notification__c notification : notifications) {       
            if (String.isNotBlank(notification.UPP_NotificationTemplate__r.Agreement_Text__c) && String.isNotBlank(notification.Merge_Data__c)) {
                String formattedMessage = mergeFields(notification.UPP_NotificationTemplate__r.Agreement_Text__c, notification.Merge_Data__c);
                notification.Message__c = formattedMessage;
                notificationsToUpdate.add(notification);
            }
        }

        // Perform the update only if there are records to modify
        if (!notificationsToUpdate.isEmpty()) {
            update notificationsToUpdate;
        }
        
        
        sendNotifications(notifications);
    }
   
    private static Void sendNotifications(List<Upp_Notification__c> newNotifications){


        for(Upp_Notification__c notification:newNotifications){
            CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'NewMessage'];
			Id userId = Userinfo.getUserId();
			Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
			customNotificationObj.setBody('Please check UPP Notification details');
			customNotificationObj.setTitle('New UPP Notification !!');
			customNotificationObj.setNotificationTypeId(cnType.id);
			customNotificationObj.setSenderId(userId);
			customNotificationObj.setTargetId(notification.Id);
			customNotificationObj.send(new Set<String> {userId});
        }
        
    }
    
    
    
     private static String mergeFields(String agreementText, String jsonData) {

        if (String.isEmpty(agreementText) || String.isEmpty(jsonData)) {
            
            return agreementText; // Return original if missing data
        }

        try {
            Map<String, Object> mergeData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

            for (String key : mergeData.keySet()) {

                  String placeholder='placeholder';

                if(key == 'PONumber'){
                       placeholder= '[PONUMBER}';
                   }
                else if(key == 'OrderNumber'){
                placeholder= '[ORDERID]';
                }
                else{
                       placeholder= '['+key.toUpperCase()+']';
                }
                
               // Convert key to uppercase to match format
                if (mergeData.get(key) != null) {
                    agreementText = agreementText.replace(placeholder, String.valueOf(mergeData.get(key)));
                }
            }
        } catch (Exception e) {
            System.debug('Error processing merge data: ' + e.getMessage());
        }

        return agreementText;
    }
    
    
 


    
}