import 'package:vidyanexis/controller/models/commercial_item_model.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/models/scope_of_work_model.dart';

class GetQuotationbyMasterIdmodel {
  final int quotationMasterId;
  final int customerId;
  final String entryDate;
  final String quotationNo;

  final String paymentTerms;
  final String paymentTermDescription;

  final String totalAmount;
  final String subsidyAmount;
  final String netTotal;

  final String productName;

  final String workCompletionPercentage;
  final String onDeliveryPercentage;
  final String advancePercentage;

  final String warranty;
  final String termsAndConditions;

  final String ksebRegistrationFee;
  final String ksebFeasibilityFee;
  final String additionalStructure;
  final String ksebSystemPrice;

  final String isConfirm;
  final String? orderNo;
  final String? orderDate;
  final String confirmedBy;

  final int quotationStatusId;
  final String quotationStatusName;
  final String activeStatus;

  final int createdBy;
  final String description;
  final String deleteStatus;
  final String createdByName;

  final String taxableAmount;
  final String gstAmount;
  final String gstPer;
  final String adCess;

  final List<QuotationDetail> quotationDetails;
  final List<BillOfMaterial> billOfMaterials;
  final List<ProductionChartModel> productionChart;
  final List<CommercialItemModel> commercialItems;
  final List<ScopeOfWorkModel> scopeOfWorkItems;

  final int quotationTypeId;
  final String quotationTypeName;
  final String cableStructure;
  final String cableType;
  final String cableShortCircuitTemp;
  final String cableStandard;
  final String cableConductorClass;
  final String cableMaterial;
  final String cableProtection;
  final String cableWarranty;
  final String cableTensileStrength;
  final String plantCapacity;
  final String moduleTechnologies;
  final String mountingStructureTechnologies;
  final String projectScheme;
  final String powerEvacuation;
  final String areaApproximate;
  final String solarPlantOutputConnection;
  final String scheme;
  final String validity;
  final String tendorNumber;
  final String paymentTermsName;
  final String incoTerms;
  final String shippingCharges;
  final String totalCgstAmount;
  final String totalSgstAmount;
  final String totalIgstAmount;
  final String otherTax;

  GetQuotationbyMasterIdmodel({
    required this.quotationMasterId,
    required this.customerId,
    required this.entryDate,
    required this.quotationNo,
    required this.paymentTerms,
    required this.paymentTermDescription,
    required this.totalAmount,
    required this.subsidyAmount,
    required this.netTotal,
    required this.productName,
    required this.workCompletionPercentage,
    required this.onDeliveryPercentage,
    required this.advancePercentage,
    required this.warranty,
    required this.termsAndConditions,
    required this.ksebRegistrationFee,
    required this.ksebFeasibilityFee,
    required this.additionalStructure,
    required this.ksebSystemPrice,
    required this.isConfirm,
    this.orderNo,
    this.orderDate,
    required this.confirmedBy,
    required this.quotationStatusId,
    required this.quotationStatusName,
    required this.activeStatus,
    required this.createdBy,
    required this.description,
    required this.deleteStatus,
    required this.createdByName,
    required this.taxableAmount,
    required this.gstAmount,
    required this.gstPer,
    required this.adCess,
    required this.quotationDetails,
    required this.billOfMaterials,
    required this.productionChart,
    required this.quotationTypeId,
    required this.quotationTypeName,
    required this.cableStructure,
    required this.cableType,
    required this.cableShortCircuitTemp,
    required this.cableStandard,
    required this.cableConductorClass,
    required this.cableMaterial,
    required this.cableProtection,
    required this.cableWarranty,
    required this.cableTensileStrength,
    required this.plantCapacity,
    required this.moduleTechnologies,
    required this.mountingStructureTechnologies,
    required this.projectScheme,
    required this.powerEvacuation,
    required this.areaApproximate,
    required this.solarPlantOutputConnection,
    required this.scheme,
    required this.validity,
    required this.tendorNumber,
    required this.paymentTermsName,
    required this.incoTerms,
    required this.commercialItems,
    required this.shippingCharges,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
    required this.totalIgstAmount,
    required this.otherTax,
    required this.scopeOfWorkItems,
  });

  factory GetQuotationbyMasterIdmodel.fromJson(Map<String, dynamic> json) {
    return GetQuotationbyMasterIdmodel(
      quotationMasterId: toInt(json['Quotation_Master_Id']),
      customerId: toInt(json['Customer_Id']),
      entryDate: toStr(json['EntryDate']),
      quotationNo: toStr(json['Quotation_No']),
      paymentTerms: toStr(json['PaymentTerms']),
      paymentTermDescription: toStr(json['Payment_Term_Description']),
      totalAmount: toStr(json['TotalAmount']),
      subsidyAmount: toStr(json['Subsidy_Amount']),
      netTotal: toStr(json['NetTotal']),
      productName: toStr(json['Product_Name']),
      advancePercentage: toStr(json['advance_percentage']),
      onDeliveryPercentage: toStr(json['onmaterialdelivery_percentage']),
      workCompletionPercentage: toStr(json['onWork_completetion_percentage']),
      warranty: toStr(json['Warranty']),
      termsAndConditions: toStr(json['Terms_And_Conditions']),
      ksebSystemPrice: toStr(json['System_Price_Excluding_KSEB_Paperwork']),
      ksebRegistrationFee: toStr(json['KSEB_Registration_Fees_KW']),
      ksebFeasibilityFee: toStr(json['KSEB_Feasibility_Study_Fees']),
      additionalStructure: toStr(json['Additional_Structure_Work']),
      isConfirm: toStr(json['Is_Confirm']),
      orderNo: json['Order_No']?.toString(),
      orderDate: json['Order_Date']?.toString(),
      confirmedBy: toStr(json['Confirmed_By']),
      quotationStatusId: toInt(json['Quotation_Status_Id']),
      quotationStatusName: toStr(json['Quotation_Status_Name']),
      activeStatus: toStr(json['Active_Status']),
      createdBy: toInt(json['Created_By']),
      description: toStr(json['Description']),
      deleteStatus: toStr(json['DeleteStatus']),
      createdByName: toStr(json['Created_By_Name']),
      taxableAmount: toStr(json['TaxableAmount']),
      gstAmount: toStr(json['TotalGSTAmount']),
      gstPer: toStr(json['TotalGSTPercent']),
      adCess: toStr(json['TotalAdCESS']),
      quotationDetails: (json['quotation_details'] as List? ?? [])
          .map((e) => QuotationDetail.fromJson(e))
          .toList(),
      billOfMaterials: (json['bill_of_materials'] as List? ?? [])
          .map((e) => BillOfMaterial.fromJson(e))
          .toList(),
      productionChart: (json['production_chart'] as List? ?? [])
          .map((e) => ProductionChartModel.fromJson(e))
          .toList(),
      quotationTypeId: toInt(json['QuotationTypeId']),
      quotationTypeName: toStr(json['QuotationTypeName']),
      cableStructure: toStr(json['CableStructure']),
      cableType: toStr(json['CableType']),
      cableShortCircuitTemp: toStr(json['CableShortCircuitTemp']),
      cableStandard: toStr(json['CableStandard']),
      cableConductorClass: toStr(json['CableConductorClass']),
      cableMaterial: toStr(json['CableMaterial']),
      cableProtection: toStr(json['CableProtection']),
      cableWarranty: toStr(json['CableWarranty']),
      cableTensileStrength: toStr(json['CableTensileStrength']),
      plantCapacity: toStr(json['PlantCapacity']),
      moduleTechnologies: toStr(json['ModuleTechnologies']),
      mountingStructureTechnologies:
          toStr(json['MountingStructureTechnologies']),
      projectScheme: toStr(json['ProjectScheme']),
      powerEvacuation: toStr(json['PowerEvacuation']),
      areaApproximate: toStr(json['AreaApproximate']),
      solarPlantOutputConnection: toStr(json['SolarPlantOutputConnection']),
      scheme: toStr(json['Scheme']),
      validity: toStr(json['Validity']),
      tendorNumber: toStr(json['TendorNumber']),
      paymentTermsName: toStr(json['Payment_Terms_Name']),
      incoTerms: toStr(json['IncoTerms']),
      commercialItems: (json['CommercialItems'] as List? ?? [])
          .map((e) => CommercialItemModel.fromJson(e))
          .toList(),
      shippingCharges: toStr(json['Shipping_Charges']),
      totalCgstAmount: toStr(json['Total_CGST_Amount']),
      totalSgstAmount: toStr(json['Total_SGST_Amount']),
      totalIgstAmount: toStr(json['Total_IGST_Amount']),
      otherTax: toStr(json['totalOther_Tax']),
      scopeOfWorkItems: (json['ScopeOfWorkItems'] as List? ?? [])
          .map((e) => ScopeOfWorkModel.fromJson(e))
          .toList(),
    );
  }
}

class QuotationDetail {
  double amount;
  dynamic itemId;
  String itemName;
  int quantity;
  double unitPrice;
  int quotationDetailsId;
  String MRP;
  double GST;
  double GSTPercent;
  double AdCESS;
  String Unit;

  QuotationDetail({
    required this.amount,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.quotationDetailsId,
    required this.MRP,
    required this.GST,
    required this.GSTPercent,
    required this.AdCESS,
    required this.Unit,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) {
    return QuotationDetail(
      amount: toDouble(json['Amount']),
      itemId: json['ItemId'],
      itemName: toStr(json['ItemName']),
      quantity: toInt(json['Quantity']),
      unitPrice: toDouble(json['UnitPrice']),
      quotationDetailsId: toInt(json['Quotation_Details_Id']),
      MRP: toStr(json['MRP']),
      GST: toDouble(json['GST']),
      GSTPercent: toDouble(json['GSTPercent']),
      AdCESS: toDouble(json['AdCESS']),
      Unit: toStr(json['Unit']),
    );
  }
}

class BillOfMaterial {
  String make;
  int quantity;
  String invoiceNo;
  String distributor;
  int billOfMaterialsId;
  String itemsAndDescription;

  BillOfMaterial({
    required this.make,
    required this.quantity,
    required this.invoiceNo,
    required this.distributor,
    required this.billOfMaterialsId,
    required this.itemsAndDescription,
  });

  factory BillOfMaterial.fromJson(Map<String, dynamic> json) {
    return BillOfMaterial(
      make: toStr(json['make']),
      quantity: toInt(json['Quantity']),
      invoiceNo: toStr(json['Invoice_No']),
      distributor: toStr(json['Distributor']),
      billOfMaterialsId: toInt(json['Bill_Of_Materials_Id']),
      itemsAndDescription: toStr(json['Items_And_Description']),
    );
  }
}

double toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  return double.tryParse(value.toString()) ?? 0.0;
}

String toStr(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}
