// Replace these IDs with valid ones in your target environment
Id userId = '005DL00000JAU1v'; // User Object record Id
Id accountId = '001DL00002XHfsQYAT'; // Account Object record Id
Id soldToCustomerId = '001DL00002XHfsQYAT'; // Account Object record Id
Id orderId = '801DL0000035zZqYAI'; // Order object record Id

// Sample data values
String documentLink = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
String fileName = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
String prefix = 'Ack_';
Long fullRandom = Crypto.getRandomInteger();
Integer randomPart = Math.abs((Integer) Math.mod(fullRandom, 10000));
String ackName = 'Ack_' + randomPart;

//Create Upp_Order_Acknowledgement__c
Upp_Order_Acknowledgement__c ack = new Upp_Order_Acknowledgement__c();
ack.User__c = userId;
ack.Account__c = accountId;
ack.Sold_To_Customer_Id__c = soldToCustomerId;
ack.Order__c = orderId;
ack.Document_Link__c = documentLink;
ack.File_Name__c = fileName;
ack.Name = ackName;
insert ack;

"RecordItems" = [
  {
 "CallReportNum":47844319,
 "OrgNum":78386,
  "ReportItemFieldNum":702225,
  "ReportItemFieldName":"Male",
 "ReportItemGroupNum":143245,
  "ReportItemGroupName":"Gender",
  "ReportItemCategoryNum":35922,
  "ReportItemCategoryName":"Caller Demographics",
  "Name":"Gender",
 "Value":"Male"
 }
 ]




