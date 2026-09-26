data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  insights_auth_function_name = var.lambda_function_names["insightsauth"]
  insights_auth_arn = var.lambda_arns["insightsauth"]

  web_auth_function_name = var.lambda_function_names["arocordinsightsAuth"]
  web_auth_arn = var.lambda_arns["arocordinsightsAuth"]
}

resource "aws_api_gateway_rest_api" "this" {
  name = "arocord-insights-api-${data.aws_region.current.name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  binary_media_types = [
    "multipart/form-data"
  ]

}


resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"

        Resource = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/*/*"
      }
    ]
  })
}

locals {
  endpoints = {

    "login-GET"                            = { path = "login", method = "GET", lambda = "login" }
    "login-count-GET"                      = { path = "login/count", method = "GET", lambda = "login" }
    "login-populate-POST"                  = { path = "login/populate", method = "POST", lambda = "login" }
    "login-email-GET"                      = { path = "login/{email}", method = "GET", lambda = "login" }
    "superadmin-login-POST"                = { path = "superadmin/login", method = "POST", lambda = "login" }

    "signup-POST"                          = { path = "signup", method = "POST", lambda = "signup" }
    "superadmin-facilities-GET"            = { path = "superadmin/facilities/{superAdminID}", method = "GET", lambda = "signup" }
    "superadmin-facility-GET"              = { path = "superadmin/facilities/{superAdminID}/{facilityID}", method = "GET", lambda = "signup" }
    "superadmin-facility-PUT"              = { path = "superadmin/facilities/{superAdminID}/{facilityID}", method = "PUT", lambda = "signup" }
    "superadmin-facility-status-PUT"       = { path = "superadmin/facilities/{superAdminID}/{facilityID}/status", method = "PUT", lambda = "signup" }
    "superadmin-facility-email-PUT"        = { path = "superadmin/facility/{superAdminID}/{adminID}/email", method = "PUT", lambda = "signup" }
    "patientfields-GET"                    = { path = "v1/patientFields", method="GET",lambda="signup"}
    "patientfields-PUT"                    = { path = "v1/patientFields", method="PUT",lambda="signup"}
    "consultationFields-GET"               = { path = "v1/consultationFields",method="GET",lambda="signup"}
    "consultationFields-PUT"               = { path = "v1/consultationFields",method="PUT",lambda="signup"}

    "insuranceinfo-POST"                   = { path = "insuranceinfo", method = "POST", lambda = "patient" }
    "insuranceinfo-PUT"                    = { path = "insuranceinfo/{insuranceID}", method = "PUT", lambda = "patient" }
    "insuranceinfo-DELETE"                 = { path = "insuranceinfo/{insuranceID}", method = "DELETE", lambda = "patient" }
    "consultation-status-PATCH"            = { path = "consultation/status/{visitID}", method = "PATCH", lambda = "patient" }
    "patientReport-arocord-PUT"            = { path = "patientReport/arocord", method = "PUT", lambda = "patient" }
    "user-GET"                             = { path = "user/{email}", method = "GET", lambda = "patient" }
    "todayVisits-GET"                      = { path = "todayVisits/{adminID}", method = "GET", lambda = "patient" }
    "todayVisits_doctor-GET"               = { path = "todayVisits/{adminID}/doctor/{doctorID}", method = "GET", lambda = "patient" }
    "patientInfo-GET"                      = { path = "patientInfo/{patientID}", method = "GET", lambda = "patient" }
    "patientInfoVisit-GET"                 = { path = "patientInfoVisit/{patientID}/{date}", method = "GET", lambda = "patient" }
    "patients-search-GET"                  = { path = "patients/search/admin/{adminID}", method = "GET", lambda = "patient" }
    "s3-presign-GET"                       = { path = "s3/presign", method = "GET", lambda = "patient" }
    "patientConsultation-POST"             = { path = "patientConsultation/{patientID}/{visitID}", method = "POST", lambda = "patient" }
    "patientConsultation-PUT"              = { path = "v2/patientConsultation/{consultationID}", method = "PUT", lambda = "patient" }
    "patientReports-POST"                  = { path = "patientReports/{patientID}", method = "POST", lambda = "patient" }
    "patientReport-DELETE"                 = { path = "patientReport/delete", method = "DELETE", lambda = "patient" }
    "patientVisit-POST"                    = { path = "patientVisit/{patientID}", method = "POST", lambda = "patient" }
    "patientVisits-PUT"                    = { path = "patientVisits/{visitID}", method = "PUT", lambda = "patient" }
    "patientVisits-DELETE"                 = { path = "patientVisits/{visitID}", method = "DELETE", lambda = "patient" }
    "patient-POST"                         = { path = "patient", method = "POST", lambda = "patient" }
    "patient-PUT"                          = { path = "patient/{patientID}", method = "PUT", lambda = "patient" }
    "patientCatalog-GET"                   = { path = "v1/catalog", method="GET", lambda = "patient"}
    "patientVisitDetails-GET"              = { path =  "v1/visit/{visitID}/details",method="GET" , lambda = "patient" }
    "patientLabs-GET"                      = { path =  "v1/labs/pending/{adminID}",method = "GET", lambda="patient"}
    "patients-adminId-GET"                 ={path="patients/admin/{adminID}",method = "GET", lambda="patient"}
    "inpatient-todayVisits-GET"            ={path ="todayVisits/inpatient/{adminID}",method = "GET", lambda="patient"}
    "patientVisit-inpatient-POST"          ={path="patientVisit/inpatient/{patientID}",method = "POST", lambda="patient" }
    "patientVisits-inpatient-visitID-PUT"         ={path="patientVisits/inpatient/{visitID}",method = "PUT", lambda="patient" }
    "patientVisits-inpatient-visitID-DELETE"      ={path="patientVisits/inpatient/{visitID}",method = "DELETE", lambda="patient" }
    "inpatient-patientConsultation-POST"          ={path ="patientConsultation/inpatient/{patientID}/{visitID}",method = "POST", lambda="patient"}
    "patientVisits-inpatient-GET"                 ={path="v1/visit/inpatient/{visitID}/details",method = "GET", lambda="patient" }
    "patientConsultation-inpatient-PUT"           ={path="v2/patientConsultation/inpatient/{consultationID}",method = "PUT", lambda="patient" }
    "patientConsultation-consultationID-PUT"      ={path="v2/patientConsultation/lab/{consultationID}",method = "PUT", lambda="patient" }
    "catalog-inpatient"                       ={path ="v1/inpatient/catalog",method="GET",lambda="patient"}
    "patient-dashboard-GET"                       ={path ="patient/dashboard/{patientID}",method = "GET",lambda="patient"}


    "arocordinsights-GET"                  = { path = "arocordinsights/{email}", method = "GET", lambda = "appinsights"}
    "arocordinsights-POST"                 = { path  = "send-email", method = "POST", lambda = "appinsights" }
    "dashboard-GET"                        = { path = "dashboard/{adminID}", method = "GET", lambda = "dashboard" }
    "doctorProfile-GET"                    = { path = "doctorProfile/{doctorID}", method = "GET", lambda = "doctor" }
    "doctorProfile-PUT"                    = { path = "doctorProfile/{doctorID}", method = "PUT", lambda = "doctor" }
    "admin-doctorsName-GET"                = { path = "admin/{adminID}/doctorsName", method = "GET", lambda = "doctor" }
    "viewPdf-GET"                          = { path = "viewPdf", method = "GET", lambda = "doctor" }

    "staff-GET"                            = { path = "staff/{adminID}", method = "GET", lambda = "caretaker" }
    "staff-POST"                           = { path = "staff", method = "POST", lambda = "caretaker" }
    "staff-caretaker-GET"                  = { path = "staff/caretaker/{caretakerID}", method = "GET", lambda = "caretaker" }
    "staff-caretaker-PUT"                  = { path = "staff/caretaker/{caretakerID}", method = "PUT", lambda = "caretaker" }
    "staff-caretaker-DELETE"               = { path = "staff/caretaker/{caretakerID}", method = "DELETE", lambda = "caretaker" }
    "staff-pesonalInfo-GET"                = { path = "staff/user/{userID}/personal-info", method = "GET", lambda = "caretaker" }
    "staff-pesonalInfo-PUT"                = { path = "staff/user/{userID}/personal-info", method = "PUT", lambda = "caretaker" }

    "clinicInfo-GET"                       = { path = "clinicInfo/{adminID}", method = "GET", lambda = "clinicinfo" }
    "clinicInfo-PUT"                       = { path = "clinicInfo/{adminID}/{facilityID}", method = "PUT", lambda = "clinicinfo" }

    "summariser-GET"                       = { path = "summariser/{patientID}", method = "GET", lambda = "aisummarizer" }
    "validate-files-POST"                  = { path = "validate-files", method = "POST", lambda = "aisummarizer" }
    "summary-pdf-POST"                     = { path = "summary-pdf", method = "POST", lambda = "aisummarizer" }
    "summary-comprehensive-POST"           = { path = "summary/comprehensive/{patient_id}", method = "POST", lambda = "aisummarizer" }
    "summary-comprehensive-status-GET"     = { path = "summary/comprehensive/status/{job_id}", method = "GET", lambda = "aisummarizer" }

    "transcriber-start-refine-POST"        = { path = "transcriber/start-refine", method = "POST", lambda = "refinenotes" }

    "transcriber-start-email-POST"         = { path = "transcriber/start-email", method = "POST", lambda = "soapemailtemplate" }

    "transcriber-start-soap-POST"          = { path = "transcriber/start-soap", method = "POST", lambda = "soapnotes" }

    "transcriber-start-transcription-POST" = { path = "transcriber/start-transcription", method = "POST", lambda = "transcription" }
    

    # lab module endpoints
    "labTest-service-POST"                 = { path = "v1/labTest/service", method ="POST", lambda= "labTechnician" }
    "labTest-service-GET"                  = { path = "v1/labTest/service", method = "GET", lambda = "labTechnician" }
    "labTest-service-id-GET"               = { path = "v1/labTest/service/{labTestID}", method = "GET", lambda = "labTechnician" }
    "labTest-service-id-PUT"               = { path = "v1/labTest/service/{labTestID}", method = "PUT", lambda = "labTechnician" }
    "labTest-service-id-DELETE"            = { path = "v1/labTest/service/{labTestID}", method = "DELETE", lambda = "labTechnician" }
    "prescribed-tests-GET"                 = { path = "v1/patientConsultation/prescribed-tests", method = "GET", lambda = "labTechnician" }
    "prescribedTest-id-DELETE"             = { path = "v1/prescribedTest/{prescribedID}", method = "DELETE", lambda = "labTechnician" }
    "prescribedTest-id-PATCH"              = { path = "v1/prescribedTest/{prescribedID}", method = "PATCH", lambda = "labTechnician" }
    "labTest-report-id-GET"                = { path = "v1/labTest/report/{labTestReportId}", method = "GET", lambda = "labTechnician" }
    "patient-lab-tests-GET"                = { path = "v1/patient/{patientID}/lab-tests", method = "GET", lambda = "labTechnician" }
    "labTest-report-POST"                  = { path = "v1/labTest/report", method = "POST", lambda = "labTechnician" }
    "labTest-report-id-PUT"                = { path = "v1/labTest/report/{labTestReportId}", method = "PUT", lambda = "labTechnician" }
    "purchase-POST"                        = { path = "v1/purchase", method = "POST", lambda = "labTechnician" }
    "purchase-id-GET"                      = { path = "v1/purchase/{purchaseID}", method = "GET", lambda = "labTechnician" }
    "purchase-id-PUT"                      = { path = "v1/purchase/{purchaseID}", method = "PUT", lambda = "labTechnician" }
    "purchase-id-DELETE"                   = { path = "v1/purchase/{purchaseID}", method = "DELETE", lambda = "labTechnician" }
    "purchase-items-filter-GET"            = { path = "v1/purchase/items/filter", method = "GET", lambda = "labTechnician" }
    "purchase-item-id-PUT"                 = { path = "v1/purchase/item/{purchaseItemID}", method = "PUT", lambda = "labTechnician" }
    "purchase-item-id-DELETE"              = { path = "v1/purchase/item/{purchaseItemID}", method = "DELETE", lambda = "labTechnician" }
    "purchase-invoice-id-GET"              = { path = "v1/purchase/invoice/{invoiceID}", method = "GET", lambda = "labTechnician" }
    "customization-labTest-GET"            =  {path  ="v1/customization/labTest/service", method = "GET", lambda = "labTechnician"}
    "customization-labTestId-GET"          =  {path  ="v1/customization/labTest/service/{labTestID}", method = "GET", lambda = "labTechnician"}


    # audit logger endpoints
    "auditLogs-GET"                        = { path = "v1/auditLogs", method = "GET", lambda = "auditlogger" }
    "auditLogFilters-GET"                  = { path = "v1/auditLogFilters", method = "GET", lambda = "auditlogger" }


    # PHARMACY MODULE ENDPOINTS
    "pharmacy-items-POST"            = { path = "pharmacy/items", method = "POST", lambda = "pharmacy" }
    "pharmacy-items-GET"             = { path = "pharmacy/items", method = "GET",  lambda = "pharmacy" }
    "pharmacy-item-id-GET"           = { path = "pharmacy/items/{itemId}", method = "GET", lambda = "pharmacy" }
    "pharmacy-item-id-PUT"           = { path = "pharmacy/items/{itemId}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-item-id-DELETE"        = { path = "pharmacy/items/{itemId}", method = "DELETE", lambda = "pharmacy" }

    "pharmacy-suppliers-POST"        = { path = "pharmacy/suppliers", method = "POST", lambda = "pharmacy" }
    "pharmacy-suppliers-GET"         = { path = "pharmacy/suppliers", method = "GET",  lambda = "pharmacy" }
    "pharmacy-supplier-id-GET"       = { path = "pharmacy/suppliers/{supplierId}", method = "GET", lambda = "pharmacy" }
    "pharmacy-supplier-id-PUT"       = { path = "pharmacy/suppliers/{supplierId}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-supplier-id-DELETE"    = { path = "pharmacy/suppliers/{supplierId}", method = "DELETE", lambda = "pharmacy" }

    "pharmacy-items-dropdown-GET"    = { path = "pharmacy/items/dropdown", method = "GET", lambda = "pharmacy" }
    "pharmacy-suppliers-dropdown-GET"= { path = "pharmacy/suppliers/dropdown", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockin-items-GET"     = { path = "pharmacy/stockin/items", method = "GET", lambda = "pharmacy" }

    "pharmacy-stockin-POST"          = { path = "pharmacy/stockin", method = "POST", lambda = "pharmacy" }
    "pharmacy-stockin-GET"           = { path = "pharmacy/stockin", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockin-id-GET"        = { path = "pharmacy/stockin/{stockinId}", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockin-id-PUT"        = { path = "pharmacy/stockin/{stockinId}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-stockin-id-DELETE"     = { path = "pharmacy/stockin/{stockinId}", method = "DELETE", lambda = "pharmacy" }

    "pharmacy-po-POST"               = { path = "pharmacy/po", method = "POST", lambda = "pharmacy" }
    "pharmacy-po-GET"                = { path = "pharmacy/po", method = "GET", lambda = "pharmacy" }
    "pharmacy-po-id-GET"             = { path = "pharmacy/po/{poId}", method = "GET", lambda = "pharmacy" }
    "pharmacy-po-id-PUT"             = { path = "pharmacy/po/{poId}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-po-tracking-GET"       = { path = "pharmacy/po/{poId}/tracking", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockin-by-po-GET"     = { path = "pharmacy/stockin/by-po/{poId}", method = "GET", lambda = "pharmacy" }

    "pharmacy-stock-adjustment-POST" = { path = "pharmacy/stock-adjustment", method = "POST", lambda = "pharmacy" }
    "pharmacy-stock-adjustment-GET"  = { path = "pharmacy/stock-adjustment", method = "GET", lambda = "pharmacy" }
    "pharmacy-stock-adjustment-id-GET" = { path = "pharmacy/stock-adjustment/{id}", method = "GET", lambda = "pharmacy" }
    "pharmacy-stock-adjustment-id-PUT" = { path = "pharmacy/stock-adjustment/{id}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-stock-adjustment-id-DELETE" = { path = "pharmacy/stock-adjustment/{id}", method = "DELETE", lambda = "pharmacy" }

    "pharmacy-stockout-POST"         = { path = "pharmacy/stockout", method = "POST", lambda = "pharmacy" }
    "pharmacy-stockout-GET"          = { path = "pharmacy/stockout", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockout-id-GET"       = { path = "pharmacy/stockout/{stockoutId}", method = "GET", lambda = "pharmacy" }
    "pharmacy-stockout-id-PUT"       = { path = "pharmacy/stockout/{stockoutId}", method = "PUT", lambda = "pharmacy" }
    "pharmacy-stockout-id-DELETE"    = { path = "pharmacy/stockout/{stockoutId}", method = "DELETE", lambda = "pharmacy" }

    "pharmacy-invoices-GET"          = { path = "pharmacy/stockout/invoices", method = "GET", lambda = "pharmacy" }
    "pharmacy-invoice-id-GET"        = { path = "pharmacy/stockout/invoices/{invoiceNo}", method = "GET", lambda = "pharmacy" }
    "pharmacy-current-stock-GET"     = { path = "pharmacy/current-stock", method = "GET", lambda = "pharmacy" }
    "pharmacy-current-stock-filter-GET" = { path = "pharmacy/current-stock/filter", method = "GET", lambda = "pharmacy" }
    "pharmacy-transactions-GET"      = { path = "pharmacy/transactions", method = "GET", lambda = "pharmacy" }
    "pharmacy-invoice-GET"           = { path = "pharmacy/invoice", method = "GET", lambda = "pharmacy" }
    

    # INPATIENT MODULE ENDPOINTS
    "inpatients-GET"                  = { path = "inpatients/{adminID}", method = "GET", lambda = "inpatient" }
    "inpatients-search-GET"           = { path = "inpatients/{adminID}/search", method = "GET", lambda = "inpatient" }
    "inpatients-detail-GET"           = { path = "inpatients/{adminID}/{visitID}", method = "GET", lambda = "inpatient" }
    "inpatients-POST"                 = { path = "inpatients/{adminID}", method = "POST", lambda = "inpatient" }
    "inpatients-id-PUT"               = { path = "inpatients/{adminID}/{visitID}", method = "PUT", lambda = "inpatient" }
    "inpatients-id-DELETE"            = { path = "inpatients/{adminID}/{visitID}", method = "DELETE", lambda = "inpatient" }
    "inpatients-transfer-history-GET" = { path = "inpatients/{adminID}/{visitID}/transfers", method = "GET", lambda = "inpatient" }
    "inpatients-transfer-POST"        = { path = "inpatients/{adminID}/{visitID}/transfer", method = "POST", lambda = "inpatient" }
    "inpatients-reactivate"           = { path  = "inpatients/{adminID}/{visitID}/reactivate", method = "POST", lambda = "inpatient"}


    # DISCHARGE MODULE ENDPOINTS
    "discharge-service-GET"                  = { path = "v1/discharge/service", method = "GET", lambda = "discharge" }
    "discharge-service-POST"                 = { path = "v1/discharge/service", method = "POST", lambda = "discharge" }
    "discharge-service-id-GET"               = { path = "v1/discharge/service/{dischargeTemplateID}", method = "GET", lambda = "discharge" }
    "discharge-service-id-PUT"               = { path = "v1/discharge/service/{dischargeTemplateID}", method = "PUT", lambda = "discharge" }
    "discharge-service-id-DELETE"            = { path = "v1/discharge/service/{dischargeTemplateID}", method = "DELETE", lambda = "discharge" }
    "inpatient-discharge-report-POST"        = { path = "inpatients/{adminID}/{visitID}/discharge/report", method = "POST", lambda = "discharge" }
    "inpatient-discharge-report-GET"         = { path = "inpatients/{adminID}/{visitID}/discharge/report", method = "GET", lambda = "discharge" }
    "inpatient-discharge-summary-GET"        = { path = "inpatients/{adminID}/{visitID}/discharge/summary", method = "GET", lambda = "discharge" }
    "inpatient-discharge-confirm-POST"       = { path = "inpatients/{adminID}/{visitID}/discharge/confirm", method = "POST", lambda = "discharge" }
    "report-types-GET"                       = { path = "report-types", method = "GET", lambda = "discharge" }
    "reports-admin-GET"                      = { path = "reports/{adminID}", method = "GET", lambda = "discharge" }
    "customization-discharge-GET"            = {path  = "v1/customization/discharge/service", method = "GET", lambda = "discharge"}
    "customization-dischargeTemplateID-GET"  = {path  = "v1/customization/discharge/service/{dischargeTemplateID}", method = "GET", lambda = "discharge"}
    "discharge-report-PUT"                   = {path  = "inpatients/{adminID}/{visitID}/discharge/report", method="PUT", lambda="discharge"}


    # WARD & BED MODULE ENDPOINTS
    "wards-GET"              = { path = "wards/{adminID}", method = "GET", lambda = "wardsbeds" }
    "wards-POST"             = { path = "wards/{adminID}", method = "POST", lambda = "wardsbeds" }
    "wards-id-PUT"           = { path = "wards/{adminID}/{wardID}", method = "PUT", lambda = "wardsbeds" }
    "wards-id-DELETE"        = { path = "wards/{adminID}/{wardID}", method = "DELETE", lambda = "wardsbeds" }
    "ward-beds-GET"          = { path = "wards/{adminID}/{wardID}/beds", method = "GET", lambda = "wardsbeds" }
    "ward-beds-POST"         = { path = "wards/{adminID}/{wardID}/beds", method = "POST", lambda = "wardsbeds" }
    "beds-available-GET"     = { path = "beds/{adminID}/available", method = "GET", lambda = "wardsbeds" }
    "beds-id-PUT"            = { path = "beds/{adminID}/{bedID}", method = "PUT", lambda = "wardsbeds" }
    "beds-id-DELETE"         = { path = "beds/{adminID}/{bedID}", method = "DELETE", lambda = "wardsbeds" }


    # BILLING / INVOICE MODULE ENDPOINTS
    "invoiceRecords-POST"                         = { path = "invoiceRecords", method = "POST", lambda = "invoiceRecords" }
    "inviceRecords-list-GET"                      = {path="invoiceRecords/admin/{adminID}/list",method = "GET", lambda = "invoiceRecords"}
    "invoiceRecords-billing-summary-GET"          = { path = "invoiceRecords/billing/admin/{adminID}", method = "GET", lambda = "invoiceRecords" }
    "invoiceRecords-single-GET"                   = { path = "invoiceRecords/admin/{adminID}/invoice/{invoiceSno}", method = "GET", lambda = "invoiceRecords" }
    "invoiceRecords-receipt-GET"                  = { path = "invoiceRecords/admin/{adminID}/invoice/receipt/{invoiceSno}", method = "GET", lambda = "invoiceRecords" }
    "invoiceRecords-list-GET"                     = { path = "invoiceRecords/admin/{adminID}", method = "GET", lambda = "invoiceRecords" }
    "invoiceRecords-id-PUT"                       = { path = "invoiceRecords/admin/{adminID}/{invoiceSno}", method = "PUT", lambda = "invoiceRecords" }
    "invoiceRecords-id-DELETE"                    = { path = "invoiceRecords/admin/{adminID}/{invoiceSno}", method = "DELETE", lambda = "invoiceRecords" }
    "invoiceRecords-pharmacy-Post"                = {path  = "invoiceRecords/pharmacy",method="POST",lambda = "invoiceRecords"}
    "invoiceRecords-pharmacy-GET"                 = {path  = "invoiceRecords/pharmacy/admin/{adminID}/list",method="GET",lambda = "invoiceRecords"}

    "invoiceRecords-pharmacy-receipt-GET"         = {path  = "invoiceRecords/pharmacy/admin/{adminID}/invoice/receipt/{invoiceSno}",method="GET",lambda = "invoiceRecords"}
    "invoiceRecords-pharmacy-invoiceSno-PUT"      = {path  = "invoiceRecords/pharmacy/admin/{adminID}/{invoiceSno}",method="PUT",lambda = "invoiceRecords"}
    "invoiceRecords-pharmacy-invoiceSno-DELETE"   = {path  = "invoiceRecords/pharmacy/admin/{adminID}/{invoiceSno}",method="DELETE",lambda = "invoiceRecords"}
   
    "invoiceRecords-lab-post"                     = {path="invoiceRecords/lab",method="POST",lambda="invoiceRecords"}
    "invoiceRecords-lab-list-GET"                 = {path="invoiceRecords/lab/admin/{adminID}/list",method="GET",lambda="invoiceRecords"}
    "invoiceRecords-lab-invoiceSno-GET"           = {path="invoiceRecords/lab/admin/{adminID}/invoice/receipt/{invoiceSno}",method="GET",lambda="invoiceRecords"}
    "invoiceRecords-lab-invoiceSno-PUT"           = {path="invoiceRecords/lab/admin/{adminID}/{invoiceSno}",method="PUT",lambda="invoiceRecords"}
    "invoiceRecords-lab-invoiceSno-DELETE"        = {path="invoiceRecords/lab/admin/{adminID}/{invoiceSno}",method="DELETE",lambda="invoiceRecords"}



    # PAYMENTS MODULE ENDPOINTS
    "payments-POST"                         = { path = "payments", method = "POST", lambda = "paymentBilling" }
    "payments-receipt-GET"                  = { path = "payments/receipt/{paymentGroupID}", method = "GET", lambda = "paymentBilling" }
    "payments-admin-GET"                    = { path = "payments/admin/{adminID}", method = "GET", lambda = "paymentBilling" }
    "payments-single-GET"                   = { path = "payments/admin/{adminID}/{paymentGroupID}", method = "GET", lambda = "paymentBilling" }
    "payments-id-PATCH"                     = { path = "payments/{paymentGroupID}", method = "PATCH", lambda = "paymentBilling" }
    "payments-id-DELETE"                    = { path = "payments/{paymentGroupID}", method = "DELETE", lambda = "paymentBilling" }
    "payments-pharmacy-POST"                = {path ="payments/pharmacy",method="POST",lambda="paymentBilling"}
    "payments-pharmacy-adminId-GET"         ={path="payments/pharmacy/admin/{adminID}",method="GET",lambda="paymentBilling"}
    "payments-pharmacy-paymentGroupID-GET"  ={path="payments/pharmacy/admin/{adminID}/{paymentGroupID}",method="GET",lambda="paymentBilling"}
    "payments-pharmacy-paymentGroupID-PATCH"       ={path="payments/pharmacy/{paymentGroupID}",method="PATCH",lambda="paymentBilling"}
    "payments-pharmacy-paymentGroupID-DELETE"      ={path="payments/pharmacy/{paymentGroupID}",method="DELETE",lambda="paymentBilling"}
    "payments-pharmacy-paymentGroupID-receipt-GET" ={path="payments/pharmacy/receipt/{paymentGroupID}",method="GET",lambda="paymentBilling"}
    "payments-lab-POST"                            ={path="payments/lab",method="POST",lambda="paymentBilling"}
    "payments-lab-adminID-GET"                     ={path="payments/lab/admin/{adminID}",method="GET",lambda="paymentBilling"}
    "payments-lab-paymentGroupID-GET"              ={path="payments/lab/admin/{adminID}/{paymentGroupID}",method="GET",lambda="paymentBilling"}
    "payments-lab-paymentGroupID-PATCH"            ={path="payments/lab/{paymentGroupID}",method="PATCH",lambda="paymentBilling"}
    "payments-lab-paymentGroupID-DELETE"           ={path="payments/lab/{paymentGroupID}",method="DELETE",lambda="paymentBilling"}
    "payments-lab-receipt-GET"                     ={path="payments/lab/receipt/{paymentGroupID}",method="GET",lambda="paymentBilling"}



    # BILLING MODULE CONFIG ENDPOINTS
    "billingModules-POST"                     = { path = "billingModules", method = "POST", lambda = "billingModule" }
    "billingModules-id-PUT"                   = { path = "billingModules/admin/{adminID}/{billingModuleID}", method = "PUT", lambda = "billingModule" }
    "billingModules-id-DELETE"                = { path = "billingModules/admin/{adminID}/{billingModuleID}", method = "DELETE", lambda = "billingModule" }
    "billingModules-admin-GET"                = { path = "billingModules/admin/{adminID}", method = "GET", lambda = "billingModule" }
    "billingModules-customization-GET"        = { path = "billingModules/customization/admin/{adminID}", method = "GET", lambda = "billingModule" }


    # BILLING SERVICES ENDPOINTS

    "billingServices-POST"            = { path = "billingServices", method = "POST", lambda = "billingServices" }
    "billingServices-id-PUT"          = { path = "billingServices/{serviceID}", method = "PUT", lambda = "billingServices" }
    "billingServices-id-DELETE"       = { path = "billingServices/{serviceID}", method = "DELETE", lambda = "billingServices" }
   
    # ADMINPANEL SERVICES ENDPOINTS
    "adminPanel-GET"                  ={path="v1/admin-panel/modules",method="GET",lambda="adminPanel"}
    "adminPanel-POST"                 ={path="v1/admin-panel/roles",method="POST",lambda="adminPanel"}
    "adminPanel-roles-GET"             ={path="v1/admin-panel/roles",method="GET",lambda="adminPanel"}
    "adminPanel-roleId-PUT"            ={path="v1/admin-panel/roles/{roleID}",method="PUT",lambda="adminPanel"}
    "adminPanel-roleId-DELETE"         ={path="v1/admin-panel/roles/{roleID}",method="DELETE",lambda="adminPanel"}
    "adminPanel-modules-POST"          ={path="v1/admin-panel/users/assign-role",method="POST",lambda="adminPanel"}
    "adminPanle-facility-GET"          ={path="v1/facility",method="GET",lambda="adminPanel"}
    "adminPanel-facility-PUT"          ={path="v1/facility",method="PUT",lambda="adminPanel"}

  }

  all_paths = distinct(flatten([
    for ep in local.endpoints : [
      for i in range(1, length(split("/", trimprefix(ep.path, "/"))) + 1) :
      join("/", slice(split("/", trimprefix(ep.path, "/")), 0, i))
    ]
  ]))

  paths_by_depth = {
    for path in local.all_paths :
    path => {
      depth  = length(split("/", path))
      parent = length(split("/", path)) > 1 ? join("/", slice(split("/", path), 0, length(split("/", path)) - 1)) : null
      part   = split("/", path)[length(split("/", path)) - 1]
    }
    if path != ""
  }
}

resource "aws_api_gateway_resource" "level1" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 1 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level2" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 2 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level1[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level3" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 3 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level2[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level4" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 4 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level3[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level5" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 5 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level4[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level6" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 6 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level5[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level7" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 7 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level6[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level8" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 8 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level7[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level9" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 9 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level8[each.value.parent].id
  path_part   = each.value.part
}

resource "aws_api_gateway_resource" "level10" {
  for_each = { for k, v in local.paths_by_depth : k => v if v.depth == 10 }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.level9[each.value.parent].id
  path_part   = each.value.part
}

locals {
  resource_ids = merge(
    { for k, v in aws_api_gateway_resource.level1 : k => v.id },
    { for k, v in aws_api_gateway_resource.level2 : k => v.id },
    { for k, v in aws_api_gateway_resource.level3 : k => v.id },
    { for k, v in aws_api_gateway_resource.level4 : k => v.id },
    { for k, v in aws_api_gateway_resource.level5 : k => v.id },
    { for k, v in aws_api_gateway_resource.level6 : k => v.id },
    { for k, v in aws_api_gateway_resource.level7 : k => v.id },
    { for k, v in aws_api_gateway_resource.level8 : k => v.id },
    { for k, v in aws_api_gateway_resource.level9 : k => v.id },
    { for k, v in aws_api_gateway_resource.level10 : k => v.id }
  )

  endpoint_paths = toset([for ep in local.endpoints : ep.path])
}

locals {
  endpoint_path_params = {
    for key, ep in local.endpoints :
    key => [
      for match in regexall("\\{([^}]+)\\}", ep.path) :
      match[0]
    ]
  }
}

locals {
  endpoint_request_parameters = {
    for key, params in local.endpoint_path_params :
    key => {
      for p in params :
      "method.request.path.${p}" => true
    }
  }
}

resource "aws_api_gateway_method" "endpoints" {
  for_each = local.endpoints

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.resource_ids[each.value.path]
  http_method = each.value.method

  authorization = (
    contains(local.no_auth_routes, each.key)           ? "NONE" :
    contains(local.lambda_authorized_routes, each.key)  ? "CUSTOM" :
    contains(local.cognito_auth_routes, each.key)       ? "COGNITO_USER_POOLS" :
    "CUSTOM"   # falls through to web_insights_auth (TOKEN type)
  )

  authorizer_id = (
    contains(local.no_auth_routes, each.key)           ? null :
    contains(local.lambda_authorized_routes, each.key)  ? aws_api_gateway_authorizer.lambda_auth.id :
    contains(local.cognito_auth_routes, each.key)       ? aws_api_gateway_authorizer.cognito_auth.id :
    aws_api_gateway_authorizer.web_insights_auth.id
  )

  request_validator_id = contains(local.no_auth_routes, each.key) ? null : aws_api_gateway_request_validator.validate_body.id

  authorization_scopes = (
    contains(local.cognito_auth_routes, each.key) ? local.cognito_scopes : null
  )

  request_parameters = lookup(local.endpoint_request_parameters, each.key, {})
}


resource "aws_api_gateway_integration" "endpoints" {
  for_each = local.endpoints

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_method.endpoints[each.key].resource_id
  http_method             = aws_api_gateway_method.endpoints[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arns[each.value.lambda]
}

resource "aws_api_gateway_method" "cors" {
  for_each = local.endpoint_paths

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = local.resource_ids[each.value]
  http_method   = "OPTIONS"
  authorization = "NONE"
}



resource "aws_api_gateway_integration" "cors" {
  for_each = local.endpoint_paths

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.resource_ids[each.value]
  http_method = aws_api_gateway_method.cors[each.value].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cors" {
  for_each = local.endpoint_paths

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.resource_ids[each.value]
  http_method = aws_api_gateway_method.cors[each.value].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each = local.endpoint_paths

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.resource_ids[each.value]
  http_method = aws_api_gateway_method.cors[each.value].http_method
  status_code = aws_api_gateway_method_response.cors[each.value].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,PATCH,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_integration.cors,
    aws_api_gateway_method_response.cors
  ]
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = local.endpoints

  statement_id  = "AllowAPIGatewayInvoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_names[each.value.lambda]
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/${each.value.method}/${replace(each.value.path, "/\\{[^}]+\\}/", "*")}"
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

 depends_on = [
    aws_api_gateway_integration.endpoints,
    aws_api_gateway_method.endpoints,

    aws_api_gateway_method.cors,
    aws_api_gateway_integration.cors,
    aws_api_gateway_method_response.cors,
    aws_api_gateway_integration_response.cors,

    aws_api_gateway_authorizer.lambda_auth,
    aws_api_gateway_authorizer.web_insights_auth,
    aws_api_gateway_authorizer.cognito_auth,
    aws_api_gateway_rest_api_policy.this
  ]

 triggers = {
    redeployment = sha1(jsonencode({
      endpoints    = local.endpoints
      cors_paths   = local.endpoint_paths
      cors_method  = "OPTIONS"
      cors_headers = "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token"
      cors_methods = "GET,POST,PUT,DELETE,PATCH,OPTIONS"
      cors_origin  = "*"
      no_auth      = local.no_auth_routes
      lambda_auth  = local.lambda_authorized_routes
      cognito_auth = local.cognito_auth_routes
      params       = local.endpoint_request_parameters
   



      # NEW: catch changes to the authorizers themselves
      lambda_auth_config = {
        uri = aws_api_gateway_authorizer.lambda_auth.authorizer_uri
        ttl = aws_api_gateway_authorizer.lambda_auth.authorizer_result_ttl_in_seconds
      }
      web_insights_auth_config = {
        uri = aws_api_gateway_authorizer.web_insights_auth.authorizer_uri
        ttl = aws_api_gateway_authorizer.web_insights_auth.authorizer_result_ttl_in_seconds
      }
      cognito_auth_config = {
        provider_arns = aws_api_gateway_authorizer.cognito_auth.provider_arns
      }
    }))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.environment
}


# Specifically for 403
resource "aws_api_gateway_gateway_response" "access_denied_403" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "ACCESS_DENIED"
  status_code   = "403"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
{
  "success": false,
  "message": "$context.authorizer.message"
}
EOF
  }
}


# Default response for other 4XX errors
resource "aws_api_gateway_gateway_response" "default_4xx" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_4XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
{
  "message": $context.error.messageString
}
EOF
  }
}


# Default response for 5XX errors
resource "aws_api_gateway_gateway_response" "default_5xx" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  response_type = "DEFAULT_5XX"

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "gatewayresponse.header.Access-Control-Allow-Methods" = "'OPTIONS'"
    "gatewayresponse.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates = {
    "application/json" = <<EOF
{
  "message": $context.error.messageString
}
EOF
  }
}

resource "aws_api_gateway_authorizer" "lambda_auth" {
  name                   = "arocord-app-insights-lambda-authorizer-${data.aws_region.current.name}"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  authorizer_uri         = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${local.insights_auth_arn}/invocations"
  authorizer_result_ttl_in_seconds = 300
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
}

resource "aws_lambda_permission" "allow_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = local.insights_auth_function_name                                                                                                                                                                                                                                                                                                             
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}

resource "aws_api_gateway_authorizer" "cognito_auth" {
  name            = "arocord-app-cognito-authorizer-${data.aws_region.current.name}"
  rest_api_id     = aws_api_gateway_rest_api.this.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = ["arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${var.user_pool_id}"]
  identity_source = "method.request.header.Authorization"
}


resource "aws_api_gateway_authorizer" "web_insights_auth" {
  name                              = "arocord-insights-auth-${data.aws_region.current.name}"
  rest_api_id                       = aws_api_gateway_rest_api.this.id
  type                               = "TOKEN"
  authorizer_uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${local.web_auth_arn}/invocations"
  identity_source                   = "method.request.header.Authorization"
  identity_validation_expression    = null   # "Token validation: None"
  authorizer_result_ttl_in_seconds  = 0      # "Authorization caching: not cached"
}

resource "aws_lambda_permission" "allow_insights_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeInsightsAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = local.web_auth_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*"
}

resource "aws_api_gateway_request_validator" "validate_body" {
  name                        = "Validate body"
  rest_api_id                 = aws_api_gateway_rest_api.this.id
  validate_request_body       = true
  validate_request_parameters = false
}



locals {
  cognito_scopes = [
    "email",
    "openid",
    "phone",
    "aws.cognito.signin.user.admin"
  ]
}


locals {
  lambda_authorized_routes = [
    "viewPdf-GET",
    "arocordinsights-GET"
  ]
}

locals{
  no_auth_routes=[
      "payments-pharmacy-paymentGroupID-receipt-GET",
      "s3-presign-GET",
      "signup-POST",
      "superadmin-facility-GET",
      "superadmin-facility-status-PUT",
      "superadmin-facility-email-PUT",
      "user-GET"    
  ]
}

 locals {
  cognito_auth_routes = [
    "validate-files-POST", "prescribed-tests-GET", "auditLogs-GET", "auditLogFilters-GET",
    "adminPanel-modules-POST", "adminPanel-roleId-PUT", "adminPanel-roleId-DELETE",
    "adminPanel-roles-GET", "adminPanel-POST", "transcriber-start-transcription-POST",
    "transcriber-start-soap-POST", "transcriber-start-refine-POST", "transcriber-start-email-POST",
    "superadmin-login-POST","superadmin-facilities-GET",
    "summary-pdf-POST", "summary-comprehensive-status-GET", "summary-comprehensive-POST",
    "summariser-GET", "staff-caretaker-DELETE", "staff-caretaker-PUT", "staff-caretaker-GET",
    "staff-GET", "staff-POST", "arocordinsights-POST", "clinicInfo-PUT", "clinicInfo-GET",
    "consultation-status-PATCH","patient-dashboard-GET", "dashboard-GET", "doctorProfile-GET", "doctorProfile-PUT",
    "inpatients-id-DELETE", "inpatients-id-PUT", "inpatients-detail-GET",
    "inpatient-discharge-report-GET", "inpatients-transfer-history-GET", "inpatients-search-GET",
    "login-count-GET", "login-GET", "login-populate-POST", "login-email-GET",
    "patientInfoVisit-GET", "patientReport-arocord-PUT", "patients-search-GET","invoiceRecords-list-GET","superadmin-facility-PUT",
    "staff-pesonalInfo-GET","staff-pesonalInfo-PUT"
    ]
}