public without sharing class UPPUserPermissionSelector extends fflib_SObjectSelector {
    
    // Specify the SObject Type
    public  Schema.SObjectType getSObjectType() {
        return UPP_User_Permission__c.SObjectType;
    }
    
    // Specify the Fields to Query
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            UPP_User_Permission__c.Id,
            UPP_User_Permission__c.Permission_Set_Api_Name__c,
            UPP_User_Permission__c.Contact__c,
            UPP_User_Permission__c.Contact__r.Id
        };
    }
    
    // Method to Query Permissions by ContactId
    public List<UPP_User_Permission__c> selectPermissionsByContactId(Id contactId) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Contact__r.Id = :contactId');
        
        return (List<UPP_User_Permission__c>) Database.query(queryFactory.toSOQL());
    }
}