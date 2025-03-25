@isTest
public class UPPNotificationController_Test {
    
    @TestSetup
    static void setupTestData() {
        User ownerWithRole = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null LIMIT 1];
        Account acc = new Account(Name = 'Test Portal Account', OwnerId = ownerWithRole.Id);
        insert acc;
        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@example.com',AccountId=acc.Id);
        insert con;
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User']; // Use relevant profile
        
        User portalUser = new User(
            FirstName = 'John',
        LastName = 'Doe',
        Email = 'johndoe@example.com',
        Username = 'johndoe@example.com.community',
        Alias = 'jdoe',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        ProfileId = portalProfile.Id,
        LanguageLocaleKey = 'en_US',
        ContactId = con.Id
            );
        insert portalUser;
        
        // Create UPP Notifications
        List<UPP_Notification__c> notifications = new List<UPP_Notification__c>();
        for (Integer i = 0; i < 5; i++) {
            notifications.add(new UPP_Notification__c(Business_Area__c = 'Mixed',Is_Read__c = true,Message_Type__c = 'Missed Pickup Appointment',Subject__c = 'Subject ' + i,  Sent__c = Date.today().addDays(-i), User__c = portalUser.Id,Theme__c='Success',RecordTypeId = [Select Id from RecordType where Name = 'Active' Limit 1].Id));
        }
        insert notifications;
        
        // Create UPP_Notifications_Preferences__c
        UPP_Notifications_Preferences__c preference = new UPP_Notifications_Preferences__c(
            User__c = portalUser.Id,
        Preferences__c = 'Missed Pickup Appointment;Past Due Shipment;',
        Deliver_Message_By_Email__c = true,
        Records_Per_Page__c = 5,
        Name = 'Test Preferences',
        OwnerId = portalUser.Id
            );
        insert preference;
        
        // Create UPP_User_Permission__c
        insert new List<UPP_User_Permission__c>{
            new UPP_User_Permission__c(
                Contact__c = portalUser.ContactId,
            Permission_Set_Api_Name__c = 'CZ_Missed_Pickup_Appointment',
            Account__c = acc.Id,
            UPP_Permission_Key__c='110000001',
            UPP_Program_Permission_Id__c ='1100000002'
                ),
            new UPP_User_Permission__c(
                Contact__c = portalUser.ContactId,
            Permission_Set_Api_Name__c = 'CZ_Past_Due_Shipment',
            Account__c = acc.Id,
            UPP_Permission_Key__c='110000002',
            UPP_Program_Permission_Id__c ='1100000003'
                )
        };
    }
    
    @isTest
    static void testGetUserNotifications() {
        Test.startTest();
        User runningTestPortalUser = [Select Id from User Where username='johndoe@example.com.community'];
        System.runAs(runningTestPortalUser){
            List<UPP_Notification__c> result = UPPNotificationController.getUserNotifications(
                Date.today().addDays(-1), Date.today().addDays(1), false, 'Read', 'Missed Pickup Appointment', 'Missed Pickup Appointment'
                );
            
            System.assertNotEquals(0, result.size());
        }
        
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetUppNotificationPreferences() {
        Test.startTest();
        
        User runningTestPortalUser = [Select Id from User Where username='johndoe@example.com.community'];
        
        System.runAs(runningTestPortalUser){
            List<UPP_Notifications_Preferences__c> preferences = UPPNotificationController.getUppNotificationPreferences();
            System.assertEquals(1, preferences.size());
            System.assertEquals(true, preferences[0].Deliver_Message_By_Email__c);
            System.assertEquals(5, preferences[0].Records_Per_Page__c);
            System.assertEquals('Missed Pickup Appointment;Past Due Shipment', preferences[0].Preferences__c);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePreferences() {
        Test.startTest();
        User runningTestPortalUser = [Select Id from User Where username='johndoe@example.com.community'];
        system.debug('runningTestPortalUser'+runningTestPortalUser);
        
        
        
        
        System.runAs(runningTestPortalUser){
            Map<String, Object> preferences = new Map<String, Object>{
                'messageTypes' => 'Missed Pickup Appointment',
                'recordsPerPage' => 20
            };
            UPPNotificationController.saveOrUpdatePreferences(preferences);
            UPP_Notifications_Preferences__c updatedPref = [SELECT Preferences__c FROM UPP_Notifications_Preferences__c LIMIT 1];
            System.assertEquals('Missed Pickup Appointment', updatedPref.Preferences__c);
        }
        Test.stopTest();
    }
    @isTest
    static void testSavePreferences() {
        delete [Select Id from UPP_Notifications_Preferences__c];
        Map<String, Object> preferences = new Map<String, Object>{
            'messageTypes' => 'Missed Pickup Appointment',
            'recordsPerPage' => 20
        };
        UPPNotificationController.saveOrUpdatePreferences(preferences);
        UPP_Notifications_Preferences__c createdPref = [SELECT Preferences__c FROM UPP_Notifications_Preferences__c LIMIT 1];
        System.assertEquals('Missed Pickup Appointment', createdPref.Preferences__c);
    }
    
    @isTest
    static void testUpdateUppNotificationRecords() {
        
        List<UPP_Notification__c> notifications = [SELECT Id, RecordTypeId FROM UPP_Notification__c LIMIT 2];
        
        List<Map<String, String>> recordsToUpdate = new List<Map<String, String>>();
        for (UPP_Notification__c notif : notifications) {
            recordsToUpdate.add(new Map<String, String>{
                'Id' => notif.Id,
                'RecordTypeId' => notif.RecordTypeId
            });
        }
        
        Test.startTest();
        List<Map<String, String>> updatedRecords = UPPNotificationController.updateUppNotificationRecords(recordsToUpdate);
        System.assertEquals(2, updatedRecords.size());
        Test.stopTest();
    }
    
    //methods to check exceptions
    @isTest
    static void testUpdateUppNotificationRecords_Exception() {
        List<Map<String, String>> invalidRecords = new List<Map<String, String>>{
            new Map<String, String>{
                'Id' => 'InvalidId',
                'RecordTypeId' => 'InvalidRecordTypeId'
            }
        };
        
        Test.startTest();
        try {
            
            UPPNotificationController.updateUppNotificationRecords(invalidRecords);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            
            System.debug('Exception Message: ' + e.getMessage());
            System.assert(e.getMessage().contains('Script-thrown exception'),
            'Expected exception message to contain "Script-thrown exception"');
        }
        Test.stopTest();
        
    }
    @isTest
    static void testSaveOrUpdatePreferences_TypeException() {
        
        Map<String, Object> invalidPreferences = new Map<String, Object>{
            'messageTypes' => 'Type1;Type2',
            'recordsPerPage' => 'InvalidValue' // This will cause a TypeException
        };
        
        Test.startTest();
        try {
            // Call the method to trigger the exception
            UPPNotificationController.saveOrUpdatePreferences(invalidPreferences);
            System.assert(false, 'Exception should have been thrown');
        } catch (AuraHandledException e) {
            
            // Validate the exception
            System.assert(e.getMessage().contains('Script-thrown exception'),
            'Expected exception message to indicate an invalid value');
        }
        Test.stopTest();
    }
    
    
    
}