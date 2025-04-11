public inherited sharing class CZ_UserSelector extends fflib_SObjectSelector {
    // Specify the SObject Type
    public  Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }
    
    // Specify the Fields to Query
    public  List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            User.Id,
            User.ContactId
        };
    }
    
    // Method to Query User by Id
    public User selectUserById(List<Id> userIds) {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition('Id IN :userIds');
        
        List<User> users = (List<User>) Database.query(queryFactory.toSOQL());
        return users.isEmpty() ? null : users[0];
    }
    
}