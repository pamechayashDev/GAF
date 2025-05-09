public class CZ_UPP_Notification_Helper {
    
    public static void afterUppNotificationInsert(List<Upp_Notification__c> newNotifications) {
        
        
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
        
        CZ_UPPNotificationPreferenceSelector preferencesSelector =  new CZ_UPPNotificationPreferenceSelector();
        List<UPP_Notifications_Preferences__c> preferences   = preferencesSelector.selectPreferencesByUser(new List<Id>(userIds));
        
        for (UPP_Notifications_Preferences__c pref : preferences) {
            prefsByUser.put(pref.User__c, pref);
        }
        
        // Build a list of email messages.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Upp_Notification__c notif : newNotifications) {
            // Get the user’s preferences (if any)
            UPP_Notifications_Preferences__c pref = prefsByUser.get(notif.User__c);
           
            List<String> prefs = pref.Preferences__c!=null?pref.Preferences__c.split(';'):null;
            if (pref != null && prefs!=null && prefs.contains(notif.Message_Type__c)) {
                
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
                Messaging.sendEmail(emailMessages);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
        
        List<Upp_Notification__c> notificationsToUpdate = new List<Upp_Notification__c>();
        //building message text
        List<Id> notificationIds = new List<Id>();
        for (UPP_Notification__c notif : newNotifications) {
            notificationIds.add(notif.Id);
        }
        CZ_UPPNotificationSelector notificationSelector = new  CZ_UPPNotificationSelector();
        List<Upp_Notification__c> notifications = notificationSelector.selectNotificationsById(notificationIds);
        
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
        
    }
    
    
    
    
    
    private static String mergeFields(String agreementText, String jsonData) {
        
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
                    system.debug('placeholder'+placeholder);
                }
                
                // Convert key to uppercase to match format
                if (mergeData.get(key) != null) {
                    agreementText = agreementText.replace(placeholder, String.valueOf(mergeData.get(key)));
                    
                }
            }
        } catch (Exception e) {
            System.debug('Error processing merge data: ' + e.getMessage());
        }
        system.debug('agreementText'+agreementText);
        return agreementText;
    }
    
    
    
    
    
    
}