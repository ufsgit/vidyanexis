class Followup {
  DateTime nextFollowUpDate;
  int statusId;
  String statusName;
  int byUserId;
  String byUserName;
  int toUserId;
  String toUserName;
  int followUp;
  String remark;

  Followup({
    required this.nextFollowUpDate,
    required this.statusId,
    required this.statusName,
    required this.byUserId,
    required this.byUserName,
    required this.toUserId,
    required this.toUserName,
    required this.followUp,
    required this.remark,
  });

  factory Followup.fromJson(Map<String, dynamic> json) => Followup(
        nextFollowUpDate: DateTime.parse(json["Next_FollowUp_date"]),
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        byUserId: json["By_User_Id"],
        byUserName: json["By_User_Name"],
        toUserId: json["To_User_Id"],
        toUserName: json["To_User_Name"],
        followUp: json["FollowUp"],
        remark: json["Remark"],
      );

  Map<String, dynamic> toJson() => {
        "Next_FollowUp_date":
            "${nextFollowUpDate.year.toString().padLeft(4, '0')}-${nextFollowUpDate.month.toString().padLeft(2, '0')}-${nextFollowUpDate.day.toString().padLeft(2, '0')}",
        "Status_Id": statusId,
        "Status_Name": statusName,
        "By_User_Id": byUserId,
        "By_User_Name": byUserName,
        "To_User_Id": toUserId,
        "To_User_Name": toUserName,
        "FollowUp": followUp,
        "Remark": remark,
      };
}

class Lead {
  int customerId;
  String customerName;
  String contactNumber;
  String contactPerson;
  String email;
  String address1;
  String address2;
  String address3;
  String address4;
  int createdBy;
  String createdByName;
  DateTime entryDate;
  int consumerNo;
  String subDistrict;
  String village;
  String section;
  String subDivision;
  String division;
  String circle;
  String connectedLoad;
  String proposedKw;
  String roofType;
  int enquirySourceId;
  String enquirySourceName;
  String mapLink;
  String pincode;
  double projectCost;

  Lead({
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.contactPerson,
    required this.email,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    required this.createdBy,
    required this.createdByName,
    required this.entryDate,
    required this.consumerNo,
    required this.subDistrict,
    required this.village,
    required this.section,
    required this.subDivision,
    required this.division,
    required this.circle,
    required this.connectedLoad,
    required this.proposedKw,
    required this.roofType,
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.mapLink,
    required this.pincode,
    required this.projectCost,
  });

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        customerId: json["Customer_Id"],
        customerName: json["Customer_Name"],
        contactNumber: json["Contact_Number"],
        contactPerson: json["Contact_Person"],
        email: json["Email"],
        address1: json["Address1"],
        address2: json["Address2"],
        address3: json["Address3"],
        address4: json["Address4"],
        createdBy: json["Created_By"],
        createdByName: json["Created_By_Name"],
        entryDate: DateTime.parse(json["Entry_Date"]),
        consumerNo: json["Consumer_No"],
        subDistrict: json["Sub_District"],
        village: json["Village"],
        section: json["Section"],
        subDivision: json["Sub_Division"],
        division: json["Division"],
        circle: json["Circle"],
        connectedLoad: json["Connected_Load"],
        proposedKw: json["Proposed_KW"],
        roofType: json["Roof_Type"],
        enquirySourceId: json["Enquiry_Source_Id"],
        enquirySourceName: json["Enquiry_Source_Name"],
        mapLink: json["Map_Link"],
        pincode: json["Pincode"],
        projectCost: json["project_cost"]?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Contact_Number": contactNumber,
        "Contact_Person": contactPerson,
        "Email": email,
        "Address1": address1,
        "Address2": address2,
        "Address3": address3,
        "Address4": address4,
        "Created_By": createdBy,
        "Created_By_Name": createdByName,
        "Entry_Date":
            "${entryDate.year.toString().padLeft(4, '0')}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}",
        "Consumer_No": consumerNo,
        "Sub_District": subDistrict,
        "Village": village,
        "Section": section,
        "Sub_Division": subDivision,
        "Division": division,
        "Circle": circle,
        "Connected_Load": connectedLoad,
        "Proposed_KW": proposedKw,
        "Roof_Type": roofType,
        "Enquiry_Source_Id": enquirySourceId,
        "Enquiry_Source_Name": enquirySourceName,
        "Map_Link": mapLink,
        "Pincode": pincode,
        "project_cost": projectCost,
      };
}
