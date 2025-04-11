import { LightningElement, track } from "lwc";
import fetchStatementWithDocuments from "@salesforce/apex/CZ_StatementController.fetchStatementWithDocuments";

import html2canvas from "@salesforce/resourceUrl/html2canvas";
import { loadScript } from "lightning/platformResourceLoader";

const COLUMNS = [
  { label: "Item ID", fieldName: "Product2__c", type: "text" },
  { label: "Invoice Date", fieldName: "Invoice_Date__c", type: "date" },
  { label: "Due Date", fieldName: "Due_Date__c", type: "date" },
  { label: "Location", fieldName: "Location__c", type: "text" },
  { label: "Ship to City", fieldName: "Ship_to_City__c", type: "text" },
  { label: "Entry Type", fieldName: "Entry_Type__c", type: "text" },
  { label: "PO", fieldName: "PO__c", type: "text" },
  {
    label: "Original Amount",
    fieldName: "Original_Amount__c",
    type: "currency"
  },
  { label: "Amount Due", fieldName: "Amount_Due__c", type: "currency" },
  { label: "Currency", fieldName: "Currency__c", type: "text" }
];

export default class UppStatementReport extends LightningElement {
  filters = {};
  @track documentFilters = {};
  @track documents = [];
  optionsObject = {};
  showCreditInvoice = false;
  @track error;
  columns = COLUMNS;
  statementDateOptions = {};
  locationOptions = {};
  businessTypeOptions = {};
  isDownloadDisabled = true;
  jsPdfInitialized = false;

  connectedCallback() {
    Promise.all([loadScript(this, html2canvas)]).then(() => {
      console.log("html2canvasInitialized");
    });

    fetchStatementWithDocuments({
      statementFilter: this.filters,
      documentFilter: this.documentFilters
    }).then((response) => {
      let results = response.uppStatements;
      console.log(JSON.stringify(results));
      if (results.length != 0) {
        const valuesSet = new Set();
        this.statementDateOptions = results
          .filter((result) => {
            console.log("result.Statement_date__c" + result.Statement_date__c);

            if (!valuesSet.has(result.Statement_date__c)) {
              return true;
            }
            return false;
          })
          .map((result) => ({
            label:
              result.Statement_date__c.split("-")[0] +
              ", " +
              result.Statement_date__c.split("-")[1],
            value: result.Statement_date__c
          }));

        valuesSet.clear();

        this.locationOptions = results
          .filter((result) => {
            if (!valuesSet.has(result.Location__c)) {
              valuesSet.add(result.Location__c);
              return true;
            }
            return false;
          })
          .map((result) => ({
            label: result.Location__c,
            value: result.Location__c
          }));
      }
    });
  }
  isExpanded = true;
  toggleFilters() {
    this.isExpanded = !this.isExpanded;
  }

  downloadCSV() {
    if (!this.documents.length) return;

    const header = [
      "Invoice Date",
      "Due Date",
      "Location",
      "Ship to City",
      "Entry Type",
      "PO",
      "Amount Due",
      "Currency",
      "Upp Statement",
      "Original Amount",
      "Business Type",
      "Payment Status",
      "Ship to State",
      "Sold to City",
      "Sold to State"
    ];
    const rows = this.documents.map((rec) => [
      rec.Invoice_Date__c,
      rec.Due_Date__c,
      rec.Location__c,
      rec.Ship_to_City__c,
      rec.Entry_Type__c,
      rec.PO__c,
      rec.Amount_Due__c,
      rec.Currency__c,
      rec.UPP_Statement__c,
      rec.Original_Amount__c,
      rec.Business_Type__c,
      rec.Payment_Status__c,
      rec.Ship_to_State__c,
      rec.Sold_to_City__c,
      rec.Sold_to_State__c
    ]);
    console.log(JSON.stringify(this.documents));
    console.log(JSON.stringify(rows));

    let csvContent =
      "data:text/csv;charset=utf-8," +
      header.join(",") +
      "\n" +
      rows.map((e) => e.join(",")).join("\n");

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "documents.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }

  downloadPDF() {
    if (!this.documents.length) return;
    let data = JSON.stringify(this.documents);
    const encoded = btoa(data); // Base64 encode

    const vfUrl = "/apex/uppDocumentsPage?data=" + encodeURIComponent(encoded);
    window.open(vfUrl, "_blank");
  }

  downloadDocumentLink = null;
  handleFilterChange(event) {
    this.filters[event.target.name] = event.target.value;
  }
  selectedStatementId = "";
  selectedStatement = true;

  handleApplyFilters() {
    console.log("filters: ", JSON.stringify(this.filters));

    fetchStatementWithDocuments({
      statementFilter: this.filters
    })
      .then((result) => {
        console.log(result.relatedDocuments);
        console.log(
          "result.uppStatements :" + JSON.stringify(result.uppStatements)
        );

        this.documents =
          "relatedDocuments" in result ? result.relatedDocuments : [];
        if (
          result.uppStatements != undefined &&
          result.uppStatements.length != 0
        ) {
          this.selectedStatementId = result.uppStatements[0].Id;
          if (result.uppStatements[0].Document_Link__c != null) {
            this.downloadDocumentLink =
              result.uppStatements[0].Document_Link__c;
            this.isDownloadDisabled = false;
          } else {
            this.isDownloadDisabled = true;
          }

          this.selectedStatement = false;
        } else {
          this.selectedStatement = true;
          this.downloadDocumentLink = null;
          this.isDownloadDisabled = true;
        }

        console.log("Pass");
        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        console.log("Fail", error);
        this.documents = [];
      });
  }

  handleClearFilters() {
    this.filters = {};
    this.handleApplyFilters();
  }
  handleDownloadPNG() {
    if (!this.documents || this.documents.length === 0) return;

    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    const fieldsToRender = [
      "Amount_Due__c",
      "Business_Type__c",
      "Currency__c",
      "Due_Date__c",
      "Entry_Type__c",

      "Invoice_Date__c",
      "Location__c",
      "Original_Amount__c",
      "PO__c",
      "Payment_Status__c",
      "Product2__c",
      "Ship_to_City__c",
      "Ship_to_State__c",
      "Sold_to_City__c",
      "Sold_to_State__c",
      "UPP_Statement__c"
    ];

    // Set individual column widths
    const colWidths = fieldsToRender.map((field) =>
      field === "UPP_Statement__c" ? 250 : 140
    );

    const rowHeight = 34;
    const headerHeight = 40;
    const padding = 10;

    const width = colWidths.reduce((total, w) => total + w, 0) + padding * 2;
    const height = (this.documents.length + 1) * rowHeight + padding * 2;

    canvas.width = width;
    canvas.height = height;

    // Background
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, width, height);

    ctx.strokeStyle = "#000000";
    ctx.lineWidth = 1;

    // Draw header row
    ctx.font = "bold 16px Arial";
    ctx.fillStyle = "#000000";

    let x = padding;
    let y = padding;

    fieldsToRender.forEach((field, index) => {
      const header = field.replace(/__c$/, "").replace(/_/g, " ");
      const colWidth = colWidths[index];
      ctx.strokeRect(x, y, colWidth, rowHeight);
      ctx.fillText(header, x + 5, y + 22);
      x += colWidth;
    });

    // Draw data rows
    ctx.font = "14px Arial";
    y += rowHeight;

    this.documents.forEach((doc) => {
      x = padding;
      fieldsToRender.forEach((field, index) => {
        const colWidth = colWidths[index];
        const value = doc[field] ?? "—";
        ctx.strokeRect(x, y, colWidth, rowHeight);
        ctx.fillText(String(value), x + 5, y + 22);
        x += colWidth;
      });
      y += rowHeight;
    });

    // Download PNG
    const link = document.createElement("a");
    link.download = "UPP_Documents_All_Records.png";
    link.href = canvas.toDataURL("image/png");
    link.click();
  }
  handleDownloadDoc() {
    if (this.downloadDocumentLink != null) {
      window.open(this.downloadDocumentLink);
    }
  }
}
