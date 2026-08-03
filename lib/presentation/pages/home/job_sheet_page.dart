import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/job_sheet_provider.dart';import 'package:vidyanexis/http/http_urls.dart';

import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

import 'package:vidyanexis/presentation/widgets/customer/pdf/job_sheet_pdf.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

import 'package:vidyanexis/presentation/widgets/signature_screen.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:printing/printing.dart';



class JobSheetPage extends StatefulWidget {

  final int taskId;

  final int customerId;

  const JobSheetPage(

      {required this.taskId, required this.customerId, super.key});



  @override

  State<JobSheetPage> createState() => _JobSheetPageState();

}



class _JobSheetPageState extends State<JobSheetPage> {

  @override

  void initState() {

    WidgetsBinding.instance.addPostFrameCallback((_) {

      JobSheetProvider jobSheetProvider =

          Provider.of<JobSheetProvider>(context, listen: false);

      jobSheetProvider.clearFormData();

      jobSheetProvider.getJobSheet(context, widget.taskId);

    });

    super.initState();

  }



  @override

  Widget build(BuildContext context) {

    final jobSheetProvider = Provider.of<JobSheetProvider>(context);

    final customerDetailsProvider =

        Provider.of<CustomerDetailsProvider>(context);



    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(

        title: const Text("Job Sheet"),

        backgroundColor: Colors.white,

        surfaceTintColor: Colors.white,

        actions: [

          IconButton(

            onPressed: () async {

              Loader.showLoader(context);



              await customerDetailsProvider.fetchLeadDetails(

                  widget.customerId.toString(), context);

              // await settingsprovider.getCompanyDetails();

              final settingsprovider = Provider.of<SettingsProvider>(context, listen: false);
              await generateJobSheetPdf(
                  jobSheet: jobSheetProvider.jobSheet[0],
                  customerData: customerDetailsProvider.leadDetails![0],
                  companyLogoUrl: settingsprovider.logo,
                  companyTitle: settingsprovider.title,
                  isShare: true);

              Loader.stopLoader(context);

            },

            icon: Icon(Icons.share, color: AppColors.primaryBlue),

          ),

          const SizedBox(width: 8),

          ElevatedButton(

            onPressed: () async {

              Loader.showLoader(context);



              await customerDetailsProvider.fetchLeadDetails(

                  widget.customerId.toString(), context);

              // await settingsprovider.getCompanyDetails();

              final settingsprovider = Provider.of<SettingsProvider>(context, listen: false);
              await generateJobSheetPdf(
                  jobSheet: jobSheetProvider.jobSheet[0],
                  customerData: customerDetailsProvider.leadDetails![0],
                  companyLogoUrl: settingsprovider.logo,
                  companyTitle: settingsprovider.title);

              Loader.stopLoader(context);

            },

            style: ElevatedButton.styleFrom(

              backgroundColor: AppColors.primaryBlue,

              foregroundColor: Colors.white,

            ),

            child: const Text('Print'),

          ),

          const SizedBox(width: 10),

        ],

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            // Task Type

            CommonDropdown<int>(

              hintText: 'Select Service type',

              items: jobSheetProvider.taskTypes,

              controller: jobSheetProvider.taskTypeController,

              onItemSelected: jobSheetProvider.setTaskType,

              selectedValue: jobSheetProvider.selectedTaskType,

            ),

            const SizedBox(height: 16),



            // Weather Condition

            CustomTextField(

              controller: jobSheetProvider.weatherConditionController,

              hintText: 'Weather Condition',

              labelText: '',

              height: 54,

            ),

            const SizedBox(height: 16),



            // Action Taken

            CustomTextField(

              controller: jobSheetProvider.actionTakenController,

              hintText: 'Action Taken',

              labelText: '',

              height: 54,

            ),

            const SizedBox(height: 16),



            // Observations

            CustomTextField(

              controller: jobSheetProvider.observationController,

              hintText: 'Observations & Issues',

              labelText: '',

              height: 54,

              keyboardType: TextInputType.multiline,

            ),

            const SizedBox(height: 16),



            // Next Scheduled Date

            const Text("Next Scheduled Date",

                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            CustomTextField(

              controller: jobSheetProvider.nextScheduledDateController,

              hintText: 'Date',

              readOnly: true,

              onTap: () => jobSheetProvider.selectNextScheduledDate(context),

              labelText: '',

              height: 54,

            ),

            const SizedBox(height: 8),

            CommonDropdown<int>(

              hintText: 'Select Schedule Type',

              items: jobSheetProvider.scheduleDateTypes,

              controller: jobSheetProvider.selectedScheduleDateName,

              onItemSelected: jobSheetProvider.setScheduleDateType,

              selectedValue: jobSheetProvider.selectedScheduleDateType,

            ),

            const SizedBox(height: 16),



            // Customer Satisfaction

            const Text("Customer Feedback",

                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            CommonDropdown<int>(

              hintText: 'Overall Satisfaction',

              items: jobSheetProvider.satisfactionLevels,

              controller: jobSheetProvider.satisfactionController,

              onItemSelected: jobSheetProvider.setSatisfactionId,

              selectedValue: jobSheetProvider.selectedSatisfactionId,

            ),

            const SizedBox(height: 8),



            CustomTextField(

              controller: jobSheetProvider.remarkController,

              hintText: 'Additional Remark',

              labelText: '',

              height: 54,

            ),

            const SizedBox(height: 16),



            // System Performance Check

            const Text("System Performance Check",

                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            ...jobSheetProvider.systemCheckControllers.map((check) => Padding(

                  padding: const EdgeInsets.only(bottom: 16),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: [

                          Text(
                            check.component,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Checkbox(
                            value: check.componentStatus == 1,
                            onChanged: (status) {
                               jobSheetProvider.setSystemComponentStatus(check, status);
                            },
                          ),

                        ],

                      ),

                      const SizedBox(height: 8),

                      CustomTextField(
                        controller: check.remarkController,
                        hintText: 'Remark',
                        labelText: '',
                        height: 54,
                      ),

                    ],

                  ),

                )),

            const SizedBox(height: 24),



            // Cleaning & Maintenance Tasks

            const Text("Cleaning & Maintenance Tasks",

                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            ...jobSheetProvider.maintenanceTasks.map((task) => Padding(

                  padding: const EdgeInsets.only(bottom: 20),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 200),
                        child: Text(task.taskName,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ),

                      Row(

                        children: [

                          const SizedBox(width: 8),

                          Expanded(
                            child: CheckboxListTile(
                              title: const Text("Yes"),
                              value: task.isYes == 1,
                              onChanged: (val) {
                                jobSheetProvider.toggleTask(task, 'yes');
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),

                          Expanded(
                            child: CheckboxListTile(
                              title: const Text("No"),
                              value: task.isNo == 1,
                              onChanged: (val) {
                                jobSheetProvider.toggleTask(task, 'no');
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),

                          Expanded(
                            child: CheckboxListTile(
                              title: const Text("N/A"),
                              value: task.notApplicable == 1,
                              onChanged: (val) {
                                jobSheetProvider.toggleTask(task, 'na');
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),

                        ],

                      ),

                    ],

                  ),

                )),

            CustomTextField(

              controller: jobSheetProvider.nextMeterReadingController,

              hintText: 'Net Meter Reading (Today)',

              labelText: 'kWh',

              height: 54,

            ),

            const SizedBox(height: 24),

            Row(

              children: [

                Expanded(

                  child: Column(

                    children: [

                      CustomOutlinedSvgButton(

                        onPressed: () async {

                          showDialog(

                            context: context,

                            builder: (BuildContext context) {

                              return const AlertDialog(

                                backgroundColor: Colors.white,

                                surfaceTintColor: Colors.white,

                                content: SizedBox(

                                  width: double.maxFinite,

                                  child: SignatureUploadPage(

                                    customerSignature: true,

                                  ),

                                ),

                              );

                            },

                          );



                          jobSheetProvider.customerSignatureDate.text =

                              DateTime.now().toIso8601String().split('T').first;

                        },

                        backgroundColor: Colors.white,

                        foregroundColor: AppColors.primaryBlue,

                        borderSide: BorderSide(color: AppColors.primaryBlue),

                        svgPath: 'assets/images/Plus.svg',

                        label: "Upload Customer Signature",

                      ),

                      const SizedBox(height: 8),

                      const Text('Customer Signature'),

                      const SizedBox(height: 8),

                      if (jobSheetProvider.customerSignatureImage.isNotEmpty)

                        Image.network(

                          HttpUrls.imgBaseUrl +

                              jobSheetProvider.customerSignatureImage,

                          height: 100,

                        ),

                    ],

                  ),

                ),

                const SizedBox(width: 20),

                Expanded(

                  child: Column(

                    children: [

                      CustomOutlinedSvgButton(

                        onPressed: () async {

                          showDialog(

                            context: context,

                            builder: (BuildContext context) {

                              return const AlertDialog(

                                backgroundColor: Colors.white,

                                surfaceTintColor: Colors.white,

                                content: SizedBox(

                                  width: double.maxFinite,

                                  child: SignatureUploadPage(

                                    customerSignature: false,

                                  ),

                                ),

                              );

                            },

                          );



                          jobSheetProvider.technicianSignatureDate.text =

                              DateTime.now().toIso8601String().split('T').first;

                        },

                        backgroundColor: Colors.white,

                        foregroundColor: AppColors.primaryBlue,

                        borderSide: BorderSide(color: AppColors.primaryBlue),

                        svgPath: 'assets/images/Plus.svg',

                        label: "Upload Technician Signature",

                      ),

                      const SizedBox(height: 8),

                      const Text('Technician Signature'),

                      const SizedBox(height: 8),

                      if (jobSheetProvider.technicianSignatureImage.isNotEmpty)

                        Image.network(

                          HttpUrls.imgBaseUrl +

                              jobSheetProvider.technicianSignatureImage,

                          height: 100,

                        ),

                    ],

                  ),

                ),

              ],

            ),

            const SizedBox(height: 40),

            // // Submit Button

            // ElevatedButton(

            //   onPressed: () {

            //     jobSheetProvider.setTaskId(widget.taskId);

            //     jobSheetProvider.submitJobSheet(context);

            //   },

            //   style: ElevatedButton.styleFrom(

            //     backgroundColor: AppColors.primaryBlue,

            //     foregroundColor: Colors.white,

            //   ),

            //   child: const Text('Save'),

            // ),

          ],

        ),

      ),

      bottomNavigationBar: Padding(

        padding: const EdgeInsets.all(16.0),

        child: ElevatedButton(

          onPressed: () {

            jobSheetProvider.setTaskId(widget.taskId);

            jobSheetProvider.submitJobSheet(context);

          },

          style: ElevatedButton.styleFrom(

            backgroundColor: AppColors.primaryBlue,

            foregroundColor: Colors.white,

            minimumSize: const Size.fromHeight(48),

          ),

          child: const Text('Save'),

        ),

      ),

    );

  }

}