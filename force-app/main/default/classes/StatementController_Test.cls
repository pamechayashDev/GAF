/**
 * @description       : 
 * @author            : rob.rastovich@gaf.com
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : rob.rastovich@gaf.com
**/
@isTest
private class StatementController_Test {

    private static void setupTestData() {
         
        
        // Insert a sample Upp_Statement__c record
        Upp_Statement__c statement = new Upp_Statement__c(
            Location__c = 'New York',
            Statement_date__c = Date.valueOf('2025-03-28'),
            User__c = UserInfo.getUserId()
            
        );
        insert statement;
         
        Product2 product = new Product2(
            Name = 'Sample Product'
        );
        insert product;
        
        // Insert a related UPP_Document__c record
        UPP_Document__c document = new UPP_Document__c(
            Upp_Statement__c = statement.Id,
            Invoice_Date__c = Date.today()
        );
        insert document;
    }

    @isTest
    static void testFetchStatementWithDocuments_WithLocationAndStatementDate() {
     
        setupTestData();
        
        // Prepare test input parameters
        Map<String, Object> statementFilter = new Map<String, Object>();
        statementFilter.put('location', 'New York');
        statementFilter.put('statementDate','2025-03-28');

        // Call the method under test
        Map<String, Object> result = StatementController.fetchStatementWithDocuments(statementFilter);
        
        // Assertions
        System.assertNotEquals(result.get('uppStatements'), null, 'uppStatements should not be null.');
        List<UPP_Statement__c> statements = (List<UPP_Statement__c>) result.get('uppStatements');
        System.assertEquals(statements.size(), 1, 'There should be one statement.');
        
        System.assertNotEquals(result.get('relatedDocuments'), null, 'relatedDocuments should not be null.');
        List<UPP_Document__c> documents = (List<UPP_Document__c>) result.get('relatedDocuments');
        System.assertEquals(documents.size(), 1, 'There should be one related document.');
    }

    @isTest
    static void testFetchStatementWithDocuments_NoLocationAndStatementDate() {
        // Setup test data
        setupTestData();

        // Prepare test input parameters (no location and statementDate)
        Map<String, Object> statementFilter = new Map<String, Object>();

        // Call the method under test
        Map<String, Object> result = StatementController.fetchStatementWithDocuments(statementFilter);
        
        // Assertions
        System.assertNotEquals(result.get('uppStatements'), null, 'uppStatements should not be null.');
        List<UPP_Statement__c> statements = (List<UPP_Statement__c>) result.get('uppStatements');
        System.assertEquals(statements.size(), 1, 'There should be one statement.');
    }

    @isTest
    static void testFetchStatementWithDocuments_NoResults() {
        // Setup test data with no records
        // Leave the filter with no data matching any records
        Map<String, Object> statementFilter = new Map<String, Object>();
        statementFilter.put('location', 'Unknown Location');
        Date todayDate=Date.today();
        statementFilter.put('statementDate','2025-03-27');

        // Call the method under test
        Map<String, Object> result = StatementController.fetchStatementWithDocuments(statementFilter);
        
        // Assertions
        System.assertEquals(result.get('uppStatements'), null, 'No results should be returned.');
    }
}