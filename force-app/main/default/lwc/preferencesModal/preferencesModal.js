import { LightningElement, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getUppNotificationPreferences from "@salesforce/apex/CZ_UPPNotificationController.getUppNotificationPreferences";
import saveOrUpdatePreferences from "@salesforce/apex/CZ_UPPNotificationController.saveOrUpdatePreferences";
import getUserPermissions from "@salesforce/apex/CZ_UPPNotificationController.getUserPermissions";

export default class PreferencesModal extends LightningElement {
  value = [];
  master;
  options = [];
  selectedValues;
  recordTypes = [];

  userProgramList = [];
  programPreferencesMapping = {};

  async connectedCallback() {
    let permissionList = await getUserPermissions();
    permissionList = [...new Set(permissionList)];

    console.log("permissionList-" + permissionList);
    this.options = permissionList.map((preference) => {
      return {
        label: preference,
        value: preference
      };
    });

    getUppNotificationPreferences().then((preferencesResult) => {
      if (preferencesResult.length != 0) {
        console.log("preferencesResult+" + preferencesResult);
        if (preferencesResult[0].Preferences__c) {
          this.selectedValues = preferencesResult[0].Preferences__c;
          this.value = preferencesResult[0].Preferences__c.split(";");
        }
      }
    });

    console.log("preference Modal called");
  }

  handleChange(e) {
    this.value = e.detail.value;
    this.selectedValues = this.value.join(";");
  }
  handleClose() {
    this.dispatchEvent(new CustomEvent("close"));
  }
  handleSave() {
    let args = {
      messageTypes: this.selectedValues
    };

    saveOrUpdatePreferences({ preferences: args })
      .then(() => {
        this.showToast(
          "Success",
          "UPP Notification Preferences Saved",
          "Success"
        );
        this.isModalOpen = false;
        this.handleClose();
      })
      .catch((error) => {
        this.showToast(
          "Failed",
          "Error in saving UPP Notification Preferences",
          "Failed"
        );
      });
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title,
      message,
      variant
    });
    this.dispatchEvent(event);
  }
}
