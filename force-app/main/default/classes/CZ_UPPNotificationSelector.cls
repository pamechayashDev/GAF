/**
 * @description       : 
 * @author            : rob.rastovich@gaf.com
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : rob.rastovich@gaf.com
**/
public inherited sharing class CZ_UPPNotificationSelector extends fflib_SObjectSelector {
    // Constructor for fflib
    
    
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            UPP_Notification__c.Id,
            UPP_Notification__c.Business_Area__c,
            UPP_Notification__c.Is_Read__c,
            UPP_Notification__c.Message_Type__c,
            UPP_Notification__c.Subject__c,
            UPP_Notification__c.Sent__c,
            UPP_Notification__c.Message__c,
            UPP_Notification__c.User__c,
            UPP_Notification__c.User__r.Name,
            UPP_Notification__c.Related_Id__c,
            UPP_Notification__c.RecordTypeId,
            UPP_Notification__c.RecordType.Name,
            UPP_Notification__c.Related_Link__c,
            UPP_Notification__c.UPP_NotificationTemplate__c,
            UPP_Notification__c.Merge_Data__c
        };
    }
    public  Schema.SObjectType getSObjectType() {
        return UPP_Notification__c.SObjectType;
    }
    
    
    
    // Get Notifications using Filters
    public List<UPP_Notification__c> selectNotifications(
        Id currentUserId,
    Boolean showArchived,
    String messageStatus,
    String messageType,
    Date dateFrom,
    
    Date dateTo
    ) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        
        
        system.debug('showArchived'+showArchived);
        //String conditionString  =
        String recType = 'Active';
        
        String conditionString = 'User__c = :currentUserId';
        if(showArchived==false){
            // queryFactory.selectField('RecordType.Name').setCondition('RecordType.Name = Active');
            conditionString+=' AND RecordType.Name = :recType';
            system.debug('queryFactory'+queryFactory);
        }
        
        
        if (messageStatus != 'None') {
            Boolean isRead = (messageStatus == 'Unread Only') ? false : true;
            conditionString+=' AND Is_Read__c = :isRead';
        }
        if (dateFrom != null) {
            conditionString+=' AND Sent__c >= :dateFrom';
        }
        if (dateTo != null) {
            conditionString+=' AND Sent__c <= :dateTo';
        }
        if (messageType != 'None') {
            conditionString+=' AND Message_Type__c = :messageType';
        }
        queryFactory.setCondition(conditionString);
        system.debug('query---'+queryFactory);
             system.debug('query - '+queryFactory.toSOQL());
        return (List<UPP_Notification__c>) Database.query(queryFactory.toSOQL());
    }
    public List<UPP_Notification__c> selectNotificationsById(List<Id> Ids){
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.selectFields(getSObjectFieldList());
        queryFactory.selectField('UPP_NotificationTemplate__r.Agreement_Text__c');
        queryFactory.setCondition('Id IN :Ids');
        return (List<UPP_Notification__c>) Database.query(queryFactory.toSOQL());
    }
    public List<UPP_Notification__c> selectByTemplateAccount(String idAct,Set<id> idTemplate,String ord){
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(
                    new Set<String>{
                        'Account__c',
                        'Business_Area__c',
                        'Certification_Designation__c',
                        'Certification_Visibility__c',
                        'CreatedById',
                        'Dismissable__c',
                        'End_Date__c',
                        'Evaluate_As__c',
                        'Force_Refresh__c',
                        'Active__c',
                        'Is_Visible__c',
                        'LastModifiedById',
                        'Link__c',
                        'Message__c',
                        'OwnerId',
                        'Page_Visibility__c',
                        'Permission_Sets__c',
                        'Process_Id__c',
                        'RecordTypeId',
                        'Related_Id__c',
                        'Start_Date__c',
                        'Start_Enrollment__c',
                        'Start_Message__c',
                        'Template_Name__c',
                        'Theme__c',
                        'Type__c',
                        'Name',
                        'UPP_NotificationTemplate__c',
                        'UPP_NotificationTemplate__r.Notification_Type__c',
                        'UPP_NotificationTemplate__r.Agreement_Sub_Type__c'
                    }
                );
        query.setCondition('Active__c=true AND UPP_NotificationTemplate__c IN:idTemplate AND Account__c=:idAct ');
        query.setOrdering('UPP_NotificationTemplate__r.Agreement_Sub_Type__c', ord=='ASC'?fflib_QueryFactory.SortOrder.ASCENDING:fflib_QueryFactory.SortOrder.DESCENDING);
        return (List<UPP_Notification__c>)Database.query(query.toSOQL());
    }
    public UPP_Notification__c selectById(String idnt){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id=:idnt');
    
        return (UPP_Notification__c)Database.query(query.toSOQL());
    }
}