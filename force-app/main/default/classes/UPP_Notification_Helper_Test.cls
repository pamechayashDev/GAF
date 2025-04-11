@IsTest
public class UPP_Notification_Helper_Test {

    @TestSetup
    static void setupData() {
       
         User ownerWithRole = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND UserRoleId != null LIMIT 1];
        Account acc = new Account(Name = 'Test Portal Account', OwnerId = ownerWithRole.Id);
        insert acc;
        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'johndoe@example.com',AccountId=acc.Id);
        insert con;
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Community Login User']; // Use relevant profile
         
        // Create test User 
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

        // Create Notification Preferences
        UPP_Notifications_Preferences__c pref = new UPP_Notifications_Preferences__c(
        User__c = portalUser.Id,
        Preferences__c = 'Missed Pickup Appointment',
        Deliver_Message_By_Email__c = true,
        Records_Per_Page__c = 5,
        Name = 'Test Preferences',
        OwnerId = portalUser.Id
        );
        insert pref;

        // Create Notification Template
        UPP_NotificationTemplate__c template = new UPP_NotificationTemplate__c(
            Agreement_Text__c = 'PO Number: [PONUMBER}, Order Number: [ORDERID] , ExtraTest: [EXTRATEST]'
        );
        insert template;
    }

    @isTest
    static void testAfterUppNotificationInsert_Success() {

            // Create Notification with Merge Data
        UPP_Notification__c notification = new UPP_Notification__c(
            User__c = [SELECT Id FROM User where Username = 'johndoe@example.com.community' LIMIT 1].Id,
            UPP_NotificationTemplate__c = [SELECT Id FROM UPP_NotificationTemplate__c LIMIT 1].Id,
            Merge_Data__c = '{"PONumber": "12345", "OrderNumber": "67890","ExtraTest": "ExtraVal"}',
            Theme__c = 'Success'
        );
        insert notification;

        // Verify Notification Message Merge
        UPP_Notification__c updatedNotification = [SELECT Message__c FROM UPP_Notification__c WHERE Id = :notification.Id];
      
        System.assertEquals('PO Number: 12345, Order Number: 67890 , ExtraTest: ExtraVal', updatedNotification.Message__c);
        
        
    }
    
    
      @isTest
    static void testAfterUppNotificationInsert_WithoutUser() {
   
            // Create Notification with Merge Data
        UPP_Notification__c notification = new UPP_Notification__c(
            UPP_NotificationTemplate__c = [SELECT Id FROM UPP_NotificationTemplate__c LIMIT 1].Id,
            Merge_Data__c = '{"PONumber": "12345", "OrderNumber": "67890", "ExtraTest": "ExtraVal"}',
            Theme__c = 'Success'
        );
        insert notification;
            
        // Verify Notification Message Merge
        UPP_Notification__c updatedNotification = [SELECT Message__c FROM UPP_Notification__c WHERE Id = :notification.Id];
          
        System.assertEquals('PO Number: 12345, Order Number: 67890 , ExtraTest: ExtraVal', updatedNotification.Message__c);
        
        
    }
    
     @isTest
    public static void testMergeFields_ExceptionHandling() {

        // Set up invalid JSON data to trigger an exception
        String invalidJson = '{ "PONumber": "12345", "OrderNumber": "67890" '; // Missing closing brace
        UPP_Notification__c notification = new UPP_Notification__c(
            User__c = [SELECT Id FROM User where Username = 'johndoe@example.com.community' LIMIT 1].Id,
            UPP_NotificationTemplate__c = [SELECT Id FROM UPP_NotificationTemplate__c LIMIT 1].Id,
            Merge_Data__c = invalidJson,
            Theme__c = 'Success'
        );
  

        
        // Execute the mergeFields method with invalid JSON to trigger an exception
        Test.startTest();
        try {
               insert notification;
        } catch (Exception e) {
            // Ensure the exception is caught
            System.debug('Caught exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
}