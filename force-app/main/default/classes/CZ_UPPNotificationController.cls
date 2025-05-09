/**
 * @description       :
 * @author            : rob.rastovich@gaf.com
 * @group             :
 * @last modified on  : 04-14-2025
 * @last modified by  : rob.rastovich@gaf.com
 **/
public with sharing class CZ_UPPNotificationController {
	@AuraEnabled
	public static List<UPP_Notification__c> getUserNotifications(
		Date dateFrom,
		Date dateTo,
		Boolean showArchived,
		String messageStatus,
		String messageType
	) {
		Id currentUserId = UserInfo.getUserId();

		CZ_UPPNotificationSelector notificationSelector = new CZ_UPPNotificationSelector();

		// Call selectNotifications from the selector
		return notificationSelector.selectNotifications(
			currentUserId,
			showArchived,
			messageStatus,
			messageType,
			dateFrom,
			dateTo
		);
	}

	@AuraEnabled
	public static List<UPP_Notifications_Preferences__c> getUppNotificationPreferences() {
		CZ_UPPNotificationPreferenceSelector preferencesSelector = new CZ_UPPNotificationPreferenceSelector();
		List<UPP_Notifications_Preferences__c> preferencesList = preferencesSelector.selectPreferencesByUser(
			new List<Id>{ UserInfo.getUserId() }
		);

		//matching preferences with permissions
		if (preferencesList.size() != 0) {
			List<String> permissions = getUserPermissions();
			Set<String> permissionsSet = new Set<String>(permissions);
			List<String> filteredPreferences = new List<String>();
			if (preferencesList[0].Preferences__c != null) {
				for (String preference : preferencesList[0].Preferences__c.split(';')) {
					if (permissionsSet.contains(preference)) {
						filteredPreferences.add(preference);
					}
				}
			}
			preferencesList[0].put('Records_Per_Page__c', Integer.valueOf(preferencesList[0].Records_Per_Page__c));
			preferencesList[0].put('Preferences__c', String.join(filteredPreferences, ';'));
		}
		return preferencesList;
	}

	@AuraEnabled
	public static void saveOrUpdatePreferences(Map<String, Object> preferences) {
		try {
			Integer recordsPerPage = 10;
			if (preferences.containsKey('recordsPerPage')) {
				recordsPerPage = Integer.valueOf(preferences.get('recordsPerPage'));
			}

			CZ_UPPNotificationPreferenceSelector preferencesSelector = new CZ_UPPNotificationPreferenceSelector();
			List<UPP_Notifications_Preferences__c> preferencesList = preferencesSelector.selectPreferencesByUser(
				new List<Id>{ UserInfo.getUserId() }
			);

			String messageTypes = '';
			if (preferences.containsKey('messageTypes')) {
				messageTypes = String.valueOf(preferences.get('messageTypes'));
			}

			if (preferencesList.isEmpty()) {
				UPP_Notifications_Preferences__c preference = new UPP_Notifications_Preferences__c(
					Preferences__c = messageTypes,
					User__c = UserInfo.getUserId(),
					Records_Per_Page__c = recordsPerPage
				);
				insert preference;
			} else {
				if (preferences.containsKey('messageTypes')) {
					preferencesList[0].Preferences__c = messageTypes;
				}
				if (preferences.containsKey('recordsPerPage')) {
					preferencesList[0].Records_Per_Page__c = recordsPerPage;
				}

				update preferencesList[0];
			}
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static List<String> getUserPermissions() {
		List<String> resultPermissions = new List<String>();

		Map<String, String> programPreferenceMapping = getProgramPreferenceMappings();
		CZ_UserSelector userSelector = new CZ_UserSelector();

		Id currentUserContactId = userSelector.selectUserById(new List<Id>{ UserInfo.getUserId() }).ContactId;
		CZ_UPPUserPermissionSelector userPermissionSelector = new CZ_UPPUserPermissionSelector();
		List<UPP_User_Permission__c> userPermissions = userPermissionSelector.selectPermissionsByContactId(
			currentUserContactId
		);

		for (UPP_User_Permission__c permission : userPermissions) {
			resultPermissions.add(programPreferenceMapping.get(permission.Permission_Set_Api_Name__c));
		}
         system.debug('resultPermissions='+resultPermissions);
		return resultPermissions;
	}

	private static Map<String, String> getProgramPreferenceMappings() {
		Map<String, String> mapping = new Map<String, String>();

		Map<String, UPP_Field_Mapping__mdt> metadataMap = UPP_Field_Mapping__mdt.getAll();

		for (UPP_Field_Mapping__mdt fieldMapping : metadataMap.values()) {
			mapping.put(fieldMapping.Program__c, fieldMapping.MasterLabel);
		}
		return mapping;
	}

	@AuraEnabled
	public static List<Map<String, String>> updateUppNotificationRecords(List<Map<String, String>> records) {
		List<UPP_Notification__c> recordsToUpdate = new List<UPP_Notification__c>();

		for (Map<String, String> rec : records) {
			UPP_Notification__c record = new UPP_Notification__c();
			record.put('Id', rec.get('Id'));
			record.put('RecordTypeId', rec.get('RecordTypeId'));
			recordsToUpdate.add(record);
		}

		try {
			update recordsToUpdate;
		} catch (DmlException e) {
			throw new AuraHandledException('Error updating records: ' + e.getMessage());
		}
		return records;
	}
}