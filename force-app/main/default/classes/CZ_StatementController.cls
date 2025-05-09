/**
 * @description       : Controller class for fetching statements and related documents
 * @author            : rob.rastovich@gaf.com
 * @group             :
 * @last modified on  : 04-21-2025
 * @last modified by  : rob.rastovich@gaf.com
 **/
public with sharing class CZ_StatementController {
	@AuraEnabled
	public static Map<String, Object> fetchStatementWithDocuments(Map<String, Object> statementFilter) {
		Map<String, Object> statementResult = new Map<String, Object>();

		system.debug(Json.serializePretty(statementFilter));
		List<UPP_Statement__c> uppStatements;
		CZ_UppStatementSelector statementSelector = new CZ_UppStatementSelector();
		CZ_UppDocumentSelector documentSelector = new CZ_UppDocumentSelector();

		if (statementFilter.containsKey('location') && statementFilter.containsKey('statementDate')) {
			String location = String.valueOf(statementFilter.get('location'));
			Date statementDate = Date.valueOf((String) statementFilter.get('statementDate'));

			uppStatements = statementSelector.selectStatementsByLocationAndDate(location, statementDate);
			system.debug('uppStatements++' + uppStatements);
			if (uppStatements.size() != 0) {
				List<UPP_Document__c> relatedDocuments = documentSelector.selectDocumentsByStatementId(
					uppStatements[0].Id
				);

				statementResult.put('uppStatements', uppStatements);
				statementResult.put('relatedDocuments', relatedDocuments);
			}
		} else {
			system.debug('non filter');

			uppStatements = statementSelector.selectStatementsByLocationAndDate(null, null);
			statementResult.put('uppStatements', uppStatements);
		}

		return statementResult;
	}
}