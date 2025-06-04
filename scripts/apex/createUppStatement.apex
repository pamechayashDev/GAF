// Replace these IDs with actual values in each environment
Id userId = '005DL00000JAU1v'; // Lookup(User)
String location = 'Bend Branch'; // Text(255)
String documentLink = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'; // URL
Date statementDate = Date.today(); // Date

// Create a UPP Statement record
UPP_Statement__c newStatement = new UPP_Statement__c();
newStatement.User__c = userId;
newStatement.Location__c = location;
newStatement.Document_Link__c = documentLink;
newStatement.Statement_date__c = statementDate;

insert newStatement;
