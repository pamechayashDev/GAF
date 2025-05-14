import { LightningElement, wire, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class UppNotifications extends NavigationMixin(
  LightningElement
) {
  isModalOpen = false;

  @api isParent;

  navigateToAllNotifications() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: `/all-notifications`
      }
    });
  }
  navigateToHome() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: `/`
      }
    });
  }

  handlePreferencesButtonClick() {
    this.isModalOpen = true;
  }
  closeModal() {
    this.isModalOpen = false;
  }
}