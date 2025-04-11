import { LightningElement, track, wire } from "lwc";
import getUserNotifications from "@salesforce/apex/CZ_UPPNotificationController.getUserNotifications";
import getUppNotificationPreferences from "@salesforce/apex/CZ_UPPNotificationController.getUppNotificationPreferences";
export default class NotificationBell extends LightningElement {
  @track notifications = [];
  @track showDropdown = false;
  @track showNotificationDot = false;
  preferencesString = "";

  // Fetch Notifications
  getNotificationData() {
    console.log("called");
    getUserNotifications({
      dateFrom: null,
      dateTo: null,
      showArchived: true,
      messageStatus: "Unread Only",
      messageType: "None",
      preferencesString: this.preferencesString
    })
      .then((data) => {
        console.log(" this.notifications--+" + this.notifications);

        this.showNotificationDot = this.notifications.some(
          (notif) => !notif.Is_Read__c
        );
        console.log(" this.notifications--" + this.notifications);
      })
      .catch((error) => {
        console.error(error);
      });
  }

  getPreferedMessageTypes() {
    getUppNotificationPreferences().then((preferencesResult) => {
      let responseString = preferencesResult[0].Preferences__c;

      this.preferencesString = responseString;

      this.getNotificationData();
    });
  }
  pollingInterval = "";
  connectedCallback() {
    // this.pollingInterval = setInterval(() => {
    //     this.getPreferedMessageTypes();
    // }, 10000);
  }

  // Toggle Dropdown
  toggleDropdown() {
    this.showDropdown = !this.showDropdown;
  }

  // Format Time Ago
  formatTimeAgo(date) {
    const seconds = Math.floor((new Date() - date) / 1000);
    if (seconds < 60) return `${seconds} seconds ago`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes} minutes ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours} hours ago`;
    const days = Math.floor(hours / 24);
    return `${days} days ago`;
  }

  get hasNotifications() {
    return this.notifications.length > 0;
  }
}