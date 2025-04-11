@IsTest
public class CZ_UPPNotificationSelector_Test {
  public final static SObjectType SOBJECT_TYPE = UPP_Notification__c.SObjectType;
  public static final List<UPP_Notification__c> EMPTY_LIST = new List<UPP_Notification__c>();
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
        System.runAs(portalUser) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'CommunityUserPermissions'];
        PermissionSetAssignment permissions = new PermissionSetAssignment(AssigneeId = portalUser.Id, PermissionSetId = permSet.Id);
        insert permissions;
        }
            
            
        List<UPP_Notification__c> notifications = new List<UPP_Notification__c>();
        for (Integer i = 0; i < 5; i++) {
            notifications.add(new UPP_Notification__c(Business_Area__c = 'Mixed',Is_Read__c = true,Message_Type__c = 'Missed Pickup Appointment',Subject__c = 'Subject ' + i,  Sent__c = Date.today().addDays(-i), User__c = portalUser.Id, Theme__c='Success',RecordTypeId = [Select Id from RecordType where Name = 'Active' Limit 1].Id));
        }
        insert notifications;
        
        }


     @IsTest
  static void shouldReturnRecordSObjectType() {
    CZ_UPPNotificationSelector selector = new CZ_UPPNotificationSelector();
    System.assertEquals(
      SOBJECT_TYPE,
      selector.getSObjectType(),
      'Expected object type returned correctly'
    );
  }
    
    @IsTest
  static void shouldReturnObjectFieldList() {
    CZ_UPPNotificationSelector selector = new CZ_UPPNotificationSelector();
    System.assertNotEquals(
      null,
      selector.getSObjectFieldList(),
      'Expected field list returned'
    );
  }
    
    
    
    
    
    
   @isTest
    public static void testSelectNotifications() {
       RecordType recordTypeActive = [SELECT Id FROM RecordType WHERE SObjectType = 'UPP_Notification__c' AND Name = 'Active' LIMIT 1];
 
        
        
        
    }
    
 
    
    
    
    
}