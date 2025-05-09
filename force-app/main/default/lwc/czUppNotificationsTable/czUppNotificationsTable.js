import { LightningElement, track, api, wire } from "lwc";
import getNotifications from "@salesforce/apex/CZ_UPPNotificationController.getUserNotifications";
import updateUppNotificationRecords from "@salesforce/apex/CZ_UPPNotificationController.updateUppNotificationRecords";
import getUppNotificationPreferences from "@salesforce/apex/CZ_UPPNotificationController.getUppNotificationPreferences";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import logo from "@salesforce/resourceUrl/logo";
import UPP_OBJECT from "@salesforce/schema/UPP_Notification__c";
import MESSAGETYPE from "@salesforce/schema/UPP_Notification__c.Message_Type__c";
import saveOrUpdatePreferences from "@salesforce/apex/CZ_UPPNotificationController.saveOrUpdatePreferences";

export default class UppNotificationsTable extends LightningElement {
  @api from;
  isParent = false;
  dateFrom = null;
  isPreferencesModalOpen = false;
  dateTo = null;
  @track sortBy;
  numberOfRecords = 10;
  @track sortDirection = "asc";
  @track currentPage = 1;
  @track isBusinessAreaSortedAsc = false;
  @track isBusinessAreaSortedDesc = false;
  @track isMessageTypeSortedAsc = false;
  @track isMessageTypeSortedDesc = false;
  @track isSentSortedAsc = false;
  @track isSentSortedDesc = false;
  preferencesString = "";
  showArchived = false;
  recordsPerPage = 10;
  @track notifications = [];
  displayValue = "None";
  messageTypeValue = "None";
  @track messageTypeOptions = [];
  columnWidths = {
    RelatedLink: 150,
    Checkbox: 30,
    Message: 150,
    Sent: 150,
    Subject: 150,
    MessageType: 200,
    BusinessArea: 150
  };
  resizingColumn = null;
  startX = 0;
  startWidth = 0;

  get totalPages() {
    return Math.ceil(this.notifications.length / this.recordsPerPage);
  }
  get paginatedRecords() {
    const start = (this.currentPage - 1) * this.recordsPerPage;
    const end = start + this.recordsPerPage;
    console.log(
      "this.notifications.slice(start, end);" +
        JSON.stringify(this.notifications.slice(start, end))
    );
    return this.notifications.slice(start, end);
  }
  nextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
    }
  }
  get isFirstPage() {
    return this.currentPage === 1;
  }

  get isLastPage() {
    return this.currentPage === this.totalPages;
  }

  // Previous Page
  previousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }
  displayOptions = [
    {
      label: "Unread Only",
      value: "Unread Only"
    },
    {
      label: "Read",
      value: "Read"
    },
    {
      label: "None",
      value: "None"
    }
  ];

  isModalOpen = false;
  logoImageUrl = logo;
  @track selectedNotification = null;

  checkedIds = [];

  allSelected = false;

  // Select/Deselect All Rows
  handleSelectAll(event) {
    this.allSelected = event.target.checked;
    this.notifications = this.notifications.map((row) => {
      this.checkedIds.push(row.Id);
      return { ...row, selected: this.allSelected };
    });
    console.log("selectAll" + JSON.stringify(this.checkedIds));
  }

  handleCheckboxChange(event) {
    let value = event.target.checked;
    let recId = event.target.dataset.id;

    if (value) {
      this.checkedIds.push(recId);
    } else {
      this.checkedIds = this.checkedIds.filter((item) => item !== recId);
      console.log(JSON.stringify(this.checkedIds));
    }
  }
  archiveSelectedRecords(event) {
    let clickedFrom = event.target.dataset.from;

    let recordsToUpdate;
    if (clickedFrom == "Multiple") {
      recordsToUpdate = this.checkedIds.map((recordId) => ({
        Id: recordId,
        RecordTypeId: this.recordTypes[2]
      }));
    } else if (clickedFrom == "Modal") {
      recordsToUpdate = [
        {
          Id: this.selectedNotification.Id,
          RecordTypeId: this.recordTypes[2]
        }
      ];
    } else {
      recordsToUpdate = [
        {
          Id: event.target.dataset.id,
          RecordTypeId: this.recordTypes[2]
        }
      ];
    }

    updateUppNotificationRecords({ records: recordsToUpdate })
      .then((res) => {
        this.applyFilters();
        this.closeModal();
        this.showToast("Success", "Archived Recoreds", "Success");
      })
      .catch((error) => {
        this.showToast("Error", "Error Occured", "Error");
      });

    this.allSelected = false;
  }

  handleSort(event) {
    const field = event.currentTarget.dataset.field;
    this.sortBy = field;
    console.log(this.sortBy);
    // Toggle Sort Direction
    this.sortDirection = this.sortDirection == "asc" ? "desc" : "asc";

    // Reset Sorting Icons
    this.isBusinessAreaSortedAsc = false;
    this.isBusinessAreaSortedDesc = false;
    this.isMessageTypeSortedAsc = false;
    this.isMessageTypeSortedDesc = false;
    this.isSentSortedAsc = false;
    this.isSentSortedDesc = false;

    // Set Sorting Icon for Current Column
    if (field === "Business_Area__c") {
      this.isBusinessAreaSortedAsc = this.sortDirection === "asc";
      this.isBusinessAreaSortedDesc = this.sortDirection === "desc";
    } else if (field === "Message_Type__c") {
      this.isMessageTypeSortedAsc = this.sortDirection === "asc";
      this.isMessageTypeSortedDesc = this.sortDirection === "desc";
    } else if (field === "Sent__c") {
      this.isSentSortedAsc = this.sortDirection === "asc";
      this.isSentSortedDesc = this.sortDirection === "desc";
    }

    // Perform Sorting
    this.notifications = [...this.notifications].sort((a, b) => {
      let valueA = a[field];
      let valueB = b[field];

      // Convert Date String to Comparable Value
      if (field === "Sent__c") {
        valueA = new Date(a[field]);
        valueB = new Date(b[field]);
      }

      let comparison = 0;
      if (valueA > valueB) {
        comparison = 1;
      } else if (valueA < valueB) {
        comparison = -1;
      }

      return this.sortDirection === "asc" ? comparison : -comparison;
    });
  }

  handleStartResize(event) {
    this.resizingColumn = event.target.dataset.column;
    this.startWidth = this.columnWidths[this.resizingColumn];
    this.startX = event.clientX;
    this.boundHandleResizing = this.handleResizing.bind(this);
    this.boundStopResizing = this.stopResizing.bind(this);
    document.addEventListener("mousemove", this.boundHandleResizing);
    document.addEventListener("mouseup", this.boundStopResizing);
  }

  handleResizing(event) {
    if (!this.resizingColumn) {
      return;
    }
    const diffX = event.clientX - this.startX;

    const newWidth = this.startWidth + diffX;
    this.columnWidths[this.resizingColumn] = newWidth;
    this.template
      .querySelectorAll(
        `td[data-column="${this.resizingColumn}"], th[data-column="${this.resizingColumn}"]`
      )
      .forEach((el) => {
        el.style.width = newWidth + "px";
      });
  }

  stopResizing = () => {
    this.resizingColumn = null;
    document.removeEventListener("mousemove", this.boundHandleResizing);
    document.removeEventListener("mouseup", this.boundStopResizing);
  };

  recordTypes = [];
  objectInfo;
  @wire(getObjectInfo, { objectApiName: UPP_OBJECT })
  wriedObjectInfo({ data, error }) {
    if (data) {
      this.objectInfo = data;
      let recordTypesData = this.objectInfo.recordTypeInfos;
      console.log("recordTypesData" + JSON.stringify(recordTypesData));
      this.recordTypes = Object.keys(recordTypesData);

      console.log("this.recordTypes" + JSON.stringify(this.recordTypes));
    } else {
      console.log("error in fetching Object Info :" + error);
    }
  }

  @track messageTypePicklistValue = [];

  @wire(getPicklistValues, {
    recordTypeId: "$this.objectInfo.defaultRecordTypeId",
    fieldApiName: MESSAGETYPE
  })
  wiredData({ data, error }) {
    if (data) {
      this.messageTypePicklistValue.push({ label: "None", value: "None" });
      this.messageTypePicklistValue = [
        ...this.messageTypePicklistValue,
        ...data.values
      ];
    } else {
      console.log("error in fetching picklist message types : " + error);
    }
  }

  @api
  getPreferedMessageTypes() {
    getUppNotificationPreferences().then((preferencesResult) => {
      console.log("preferencesResult--++" + JSON.stringify(preferencesResult));
      if (preferencesResult.length != 0) {
        this.recordsPerPage = preferencesResult[0].Records_per_page__c;
      }

      console.log(this.recordsPerPage);
      this.getNotificationData();
    });
  }

  formatDate(dateToFormat) {
    let date = new Date(dateToFormat);
    let options = {
      year: "numeric",
      month: "numeric",
      day: "numeric",
      hour: "numeric",
      minute: "numeric",
      second: "numeric",
      hour12: true
    };
    return new Intl.DateTimeFormat("en-US", options).format(date);
  }
  getNotificationData() {
    getNotifications({
      dateFrom: this.dateFrom,
      dateTo: this.dateTo,
      showArchived: this.showArchived,
      messageStatus: this.displayValue,
      messageType: this.messageTypeValue
    })
      .then((data) => {
        if (data) {
          this.notifications = this.from == "parent" ? data.slice(0, 3) : data;
          this.notifications = this.notifications.map((notification) => ({
            ...notification,
            formattedDate:
              notification.Sent__c != null
                ? this.formatDate(notification.Sent__c)
                : ""
          }));
          console.log("Data for test=" + JSON.stringify(this.notifications));
        }
      })
      .catch((error) => {
        console.error("Error retrieving notifications-1", error);
      });
  }

  async connectedCallback() {
    this.isParent = this.from == "parent" ? true : false;
    this.getPreferedMessageTypes();
  }

  handleRecordsPerPageOnBlur() {
    let args = { recordsPerPage: this.recordsPerPage };
    saveOrUpdatePreferences({ preferences: args })
      .then(() => {
        this.showToast("Success", "Saved Records Per Page", "Success");
      })
      .catch((error) => {
        this.showToast(
          "Failed",
          "Error in updating records per page",
          "Failed"
        );
      });
  }

  handleChange(event) {
    const { name, value, checked } = event.target;
    if (name === "showArchived") {
      this.showArchived = checked;
    } else if (name === "dateFrom") {
      const today = new Date().toISOString().split("T")[0];
      value > today
        ? this.showToast("Error", "From Date cannot be in the future", "error")
        : (this.dateFrom = value);
    } else {
      this[name] = value;
    }
  }

  //applying filters
  applyFilters() {
    console.log("showArchived===" + this.showArchived);
    getNotifications({
      dateFrom: this.dateFrom,
      dateTo: this.dateTo,
      showArchived: this.showArchived,
      messageStatus: this.displayValue,
      messageType: this.messageTypeValue
    })
      .then((data) => {
        if (data) {
          this.notifications = this.from == "parent" ? data.slice(0, 3) : data;

          this.isParent = this.from == "parent" ? true : false;

          this.notifications = this.notifications.map((notification) => ({
            ...notification,
            formattedDate:
              notification.Sent__c != null
                ? this.formatDate(notification.Sent__c)
                : ""
          }));

          console.log("data--" + JSON.stringify(data));
        }
      })
      .catch((error) => {
        console.error("Error retrieving notifications", JSON.stringify(error));
      });
    this.allSelected = false;
  }

  //clear all filters
  clearFilters() {
    this.dateFrom = null;
    this.dateTo = null;
    this.displayValue = "None";
    this.messageTypeValue = "None";
    this.showArchived = false;
    this.getNotificationData();
  }

  handleSubjectAction(event) {
    const notificationId = event.target.dataset.id;
    if (!notificationId) {
      console.error("Notification ID is missing");
      return;
    }

    this.selectedNotification =
      this.notifications.find((notif) => notif.Id === notificationId) || null;
    if (this.selectedNotification) {
      this.selectedNotification.Sent__c = this.formatDate(
        this.selectedNotification.Sent__c
      );

      //mark notification read
      if (!this.selectedNotification.Is_Read__c) {
        const fields = {
          Id: this.selectedNotification.Id,
          Is_Read__c: true
        };
        const recordInput = { fields };
        updateRecord(recordInput)
          .then(() => {
            this.applyFilters();
          })
          .catch((error) => {
            console.error(
              "Error updating notification:",
              JSON.stringify(error)
            );
          });
      }

      this.isModalOpen = true;
    }
  }

  closeModal() {
    this.isModalOpen = false;
    this.selectedNotification = null;
  }
  handlePreferencesButtonClick() {
    this.isPreferencesModalOpen = true;
  }
  closePreferencesModal() {
    this.isPreferencesModalOpen = false;
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