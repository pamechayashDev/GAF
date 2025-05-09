import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import jszipLib from "@salesforce/resourceUrl/jszip";
import fileSaverLib from "@salesforce/resourceUrl/fileSaver";
import { loadScript } from "lightning/platformResourceLoader";
import fetchUppOrderAcknowledgements from "@salesforce/apex/CZ_UppOrderAcknowledgementController.fetchUppOrderAcknowledgements";
const COLUMNS = [
  {
    label: "Account",
    type: "button",
    fieldName: "AccountName",
    typeAttributes: {
      label: { fieldName: "AccountName" },
      name: "openFile",
      variant: "base",
      class: "slds-text-link"
    }
  },
  {
    label: "Sales Order",
    type: "text",
    fieldName: "OrderNumber"
  },
  {
    label: "Sold to Customer",
    type: "button",
    fieldName: "CustomerName",
    typeAttributes: {
      label: { fieldName: "CustomerName" },
      name: "openAccount",
      variant: "base",
      class: "slds-text-link"
    }
  }
];
export default class CzUPPOrderAcknowledgement extends LightningElement {
  columns = COLUMNS;
  @track OrderAcknowledgements;
  @api recordId;
  selectedRows = [];
  connectedCallback() {
    fetchUppOrderAcknowledgements({ orderId: this.recordId }).then((result) => {
      this.OrderAcknowledgements = result;

      this.OrderAcknowledgements = this.OrderAcknowledgements.map((item) => ({
        ...item,
        accountUrl: item.Sold_To_Customer_Id__r.Id
          ? `/lightning/r/Contact/${item.Sold_To_Customer_Id__r.Id}/view`
          : "",
        OrderNumber: item.Order__r.OrderNumber + "",
        CustomerName: item.Sold_To_Customer_Id__r.Name,
        AccountName: item.Account__r.Name + "-" + item.Order__r.OrderNumber
      }));
      console.log("result" + JSON.stringify(this.OrderAcknowledgements));
    });

    Promise.all([loadScript(this, jszipLib), loadScript(this, fileSaverLib)])
      .then(() => {
        console.error("Zip loaded");
      })
      .catch((error) => {
        console.error("Error loading libraries:", error);
      });
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === "openFile") {
      console.log(JSON.stringify(row));
      window.open(row.File_Name__c, "_blank");
    }
    if (actionName === "openAccount") {
      console.log(JSON.stringify(row));
      window.open(row.accountUrl, "_blank");
    }
  }

  handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
  }

  async downloadCSV() {
    if (!this.selectedRows.length) {
      this.showNotification(
        "Error",
        "Please select at least one record to download.",
        "error"
      );
      return;
    }

    const header = ["Account Name", "Sales Order", "Sold to Customer"];
    const rows = this.selectedRows.map((rec) => [
      rec.AccountName,
      `="${rec.OrderNumber}"`,
      rec.CustomerName
    ]);

    let csvContent =
      "data:text/csv;charset=utf-8," +
      header.join(",") +
      "\n" +
      rows.map((e) => e.join(",")).join("\n");
    const zip = new JSZip();
    zip.file("OrderAcknowledgement.csv", csvContent);

    const blob = await zip.generateAsync({ type: "blob" });

    // Download the ZIP
    saveAs(blob, "OrderAcknowledgement.zip");

    // const encodedUri = encodeURI(csvContent);
    // const link = document.createElement("a");
    // link.setAttribute("href", encodedUri);
    // link.setAttribute("download", "OrderAcknowledgement.csv");
    // document.body.appendChild(link);
    // link.click();
    // document.body.removeChild(link);
  }

  showNotification(titleText, messageText, variant) {
    const evt = new ShowToastEvent({
      title: titleText,
      message: messageText,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}