class SolarPanelDetails {
  int solarPanelDetailsId;
  int taskId;
  int dcspdId;
  String dcspdName;
  int dcFuseId;
  String dcFuseName;
  String make;
  String amp;
  String pb1;
  String pb2;
  String pb3;
  String pb4;
  int acspdId;
  String acspdName;
  int acmcbId;
  String acmcbName;
  String acVolt;
  String phaseToEarth;
  String neutralToEarth;
  String inverterStatus;
  String panelStatus;
  String summary;
  int deleteStatus;
  String customerSign;
  String serviceEngSign;

  // Constructor
  SolarPanelDetails({
    required this.solarPanelDetailsId,
    required this.taskId,
    required this.dcspdId,
    required this.dcspdName,
    required this.dcFuseId,
    required this.dcFuseName,
    required this.make,
    required this.amp,
    required this.pb1,
    required this.pb2,
    required this.pb3,
    required this.pb4,
    required this.acspdId,
    required this.acspdName,
    required this.acmcbId,
    required this.acmcbName,
    required this.acVolt,
    required this.phaseToEarth,
    required this.neutralToEarth,
    required this.inverterStatus,
    required this.panelStatus,
    required this.summary,
    required this.deleteStatus,
    required this.customerSign,
    required this.serviceEngSign,
  });

  // Factory method to create a SolarPanelDetails from a JSON map
  factory SolarPanelDetails.fromJson(Map<String, dynamic> json) {
    return SolarPanelDetails(
      solarPanelDetailsId: json['Solar_Panel_Details_Id'] ?? 0,
      taskId: json['Task_Id'] ?? 0,
      dcspdId: json['DCSPD_Id'] ?? 0,
      dcspdName: json['DCSPD_Name'] ?? '',
      dcFuseId: json['DC_Fuse_Id'] ?? 0,
      dcFuseName: json['DC_Fuse_Name'] ?? '',
      make: json['Make'] ?? '',
      amp: json['AMP'] ?? '0.00',
      pb1: json['PB1'] ?? '0.00',
      pb2: json['PB2'] ?? '0.00',
      pb3: json['PB3'] ?? '0.00',
      pb4: json['PB4'] ?? '0.00',
      acspdId: json['ACSPD_Id'] ?? 0,
      acspdName: json['ACSPD_Name'] ?? '',
      acmcbId: json['ACMCB_Id'] ?? 0,
      acmcbName: json['ACMCB_Name'] ?? '',
      acVolt: json['AC_Volt'] ?? '0.00',
      phaseToEarth: json['Phase_To_Earth'] ?? '0.00',
      neutralToEarth: json['Neutral_To_Earth'] ?? '0.00',
      inverterStatus: json['Inverter_Status'] ?? '',
      panelStatus: json['Panel_Status'] ?? '',
      summary: json['Summary'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      customerSign: json['Customer_Sign'] ?? '',
      serviceEngSign: json['Service_Eng_Sign'] ?? '',
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Solar_Panel_Details_Id': solarPanelDetailsId,
      'Task_Id': taskId,
      'DCSPD_Id': dcspdId,
      'DCSPD_Name': dcspdName,
      'DC_Fuse_Id': dcFuseId,
      'DC_Fuse_Name': dcFuseName,
      'Make': make,
      'AMP': amp,
      'PB1': pb1,
      'PB2': pb2,
      'PB3': pb3,
      'PB4': pb4,
      'ACSPD_Id': acspdId,
      'ACSPD_Name': acspdName,
      'ACMCB_Id': acmcbId,
      'ACMCB_Name': acmcbName,
      'AC_Volt': acVolt,
      'Phase_To_Earth': phaseToEarth,
      'Neutral_To_Earth': neutralToEarth,
      'Inverter_Status': inverterStatus,
      'Panel_Status': panelStatus,
      'Summary': summary,
      'DeleteStatus': deleteStatus,
      'Customer_Sign': customerSign,
      'Service_Eng_Sign': serviceEngSign,
    };
  }
}
