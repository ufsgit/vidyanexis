import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/process_flow_model.dart';
import 'package:vidyanexis/controller/process_flow_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_add_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/add_followup_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class ProcessFlowPage extends StatefulWidget {
  const ProcessFlowPage({super.key});

  @override
  State<ProcessFlowPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<ProcessFlowPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  late ProcessFlowProvider processFlowProvider;
  bool viewProfile = false;
  late SettingsProvider settingsProvider;
  bool isLoadingData = false;

  @override
  void initState() {
    super.initState();
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    processFlowProvider =
        Provider.of<ProcessFlowProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
    });
  }

  Future<void> getData() async {
    isLoadingData = true;
    setState(() {});
    await processFlowProvider.getProcessFlow(context);
    isLoadingData = false;
    setState(() {});
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppStyles.isWebScreen(context)
          ? const SizedBox.shrink()
          : (settingsProvider.menuIsSaveMap[36] == 1
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ProcessFlowAddWidget(
                          isEdit: false,
                          processFlowModel: ProcessFlowModel(),
                        ),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                )
              : null),
      key: _scaffoldKey,
      backgroundColor: AppColors.whiteColor,
      appBar: AppStyles.isWebScreen(context)
          ? null
          : AppBar(
              title: Text(
                "Process flow",
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  // fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              leading: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textGrey4,
                  ),
                  iconSize: 24,
                ),
              ),
            ),
      body: Consumer<ProcessFlowProvider>(builder: (context, provider, child) {
        return Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  AppStyles.isWebScreen(context)
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Text(
                                'Process Flow',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF152D70),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Flexible(child: Container()),
                              Container(
                                width: MediaQuery.of(context).size.width / 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (query) {
                                    processFlowProvider.filterData(query);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search here....',
                                    prefixIcon: const Icon(Icons.search),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // String query = searchController.text;
                                          // // leadProvider.selectDateFilterOption(null);
                                          // // leadProvider.removeStatus();
                                          // print(query);
                                          // if (leadProvider.search.isNotEmpty) {
                                          //   searchController.clear();
                                          //   leadProvider.setSearchCriteria(
                                          //     '',
                                          //     leadProvider.fromDateS,
                                          //     leadProvider.toDateS,
                                          //     leadProvider.status,
                                          //     leadProvider.enquiryForS,
                                          //   );
                                          //   leadProvider.getSearchLeads(context);
                                          // } else {
                                          //   leadProvider.setSearchCriteria(
                                          //     query,
                                          //     leadProvider.fromDateS,
                                          //     leadProvider.toDateS,
                                          //     leadProvider.status,
                                          //     leadProvider.enquiryForS,
                                          //   );
                                          //   leadProvider.getSearchLeads(context);
                                          // }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.textGrey4,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Text(
                                            // leadProvider.search.isNotEmpty
                                            // ? 'Clear'
                                            // :
                                            'Search'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // OutlinedButton.icon(
                              //   onPressed: () {
                              //     leadProvider.toggleFilter();
                              //     // leadProvider.selectDateFilterOption(null);
                              //     // leadProvider.removeStatus();
                              //     // leadProvider.getSearchLeads('', '', '', '', context);
                              //     print(leadProvider.isFilter);
                              //   },
                              //   icon: const Icon(Icons.filter_list),
                              //   label: const Text('Filter'),
                              //   style: OutlinedButton.styleFrom(
                              //     foregroundColor: leadProvider.isFilter
                              //         ? Colors.white
                              //         : AppColors
                              //             .primaryBlue, // Change foreground color
                              //     backgroundColor: leadProvider.isFilter
                              //         ? const Color(0xFF5499D9)
                              //         : Colors.white, // Change background color
                              //     side: BorderSide(
                              //         color: leadProvider.isFilter
                              //             ? const Color(0xFF5499D9)
                              //             : AppColors
                              //                 .primaryBlue), // Change border color
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 16,
                              //       vertical: 12,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(width: 16),
                              // // New Lead Button
                              if (settingsProvider.menuIsSaveMap[36] == 1)
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            backgroundColor: Colors.white,
                                            content: SizedBox(
                                              width:
                                                  AppStyles.isWebScreen(context)
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3
                                                      : MediaQuery.of(context)
                                                          .size
                                                          .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: ProcessFlowAddWidget(
                                                isEdit: false,
                                                processFlowModel:
                                                    ProcessFlowModel(),
                                              ),
                                            ));
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('New Process Flow'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              // const SizedBox(width: 16),
                              // Excel Import Button
                              // ElevatedButton.icon(
                              //   onPressed: () {
                              //     context.push(BulkImportScreen.route);
                              //   },
                              //   icon: const Icon(Icons.document_scanner),
                              //   label: Text(MediaQuery.of(context).size.width > 860
                              //       ? 'Import Excel'
                              //       : ''),
                              //   style: ElevatedButton.styleFrom(
                              //     backgroundColor: AppColors.primaryBlue,
                              //     foregroundColor: Colors.white,
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 16,
                              //       vertical: 12,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      //mobile design
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            runSpacing: 10,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (query) {
                                    processFlowProvider.filterData(query);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search here....',
                                    prefixIcon: const Icon(Icons.search),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.textGrey4,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 0,
                                          ),
                                        ),
                                        child: Text(
                                            // leadProvider.search.isNotEmpty
                                            // ? 'Clear'
                                            // :
                                            'Search'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(width: 16),
                              // OutlinedButton.icon(
                              //   onPressed: () {
                              //     leadProvider.toggleFilter();
                              //     // leadProvider.selectDateFilterOption(null);
                              //     // leadProvider.removeStatus();
                              //     // leadProvider.getSearchLeads('', '', '', '', context);
                              //     print(leadProvider.isFilter);
                              //   },
                              //   icon: const Icon(Icons.filter_list),
                              //   label: const Text('Filter'),
                              //   style: OutlinedButton.styleFrom(
                              //     foregroundColor: leadProvider.isFilter
                              //         ? Colors.white
                              //         : AppColors
                              //             .primaryBlue, // Change foreground color
                              //     backgroundColor: leadProvider.isFilter
                              //         ? const Color(0xFF5499D9)
                              //         : Colors.white, // Change background color
                              //     side: BorderSide(
                              //         color: leadProvider.isFilter
                              //             ? const Color(0xFF5499D9)
                              //             : AppColors
                              //                 .primaryBlue), // Change border color
                              //     padding: const EdgeInsets.symmetric(
                              //       horizontal: 16,
                              //       vertical: 0,
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(width: 16),
                              // // New Lead Button
                              if (settingsProvider.menuIsSaveMap[36] == 1)
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ProcessFlowAddWidget(
                                            isEdit: false,
                                            processFlowModel:
                                                ProcessFlowModel(),
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('New Process Flow'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 0,
                                      ),
                                    ),
                                  ),
                                ),
                              // const SizedBox(width: 16),
                              // // Excel Import Button
                              // // ElevatedButton.icon(
                              // //   onPressed: () {
                              // //     context.push(BulkImportScreen.route);
                              // //   },
                              // //   icon: const Icon(Icons.document_scanner),
                              // //   label: Text(MediaQuery.of(context).size.width > 860
                              // //       ? 'Import Excel'
                              // //       : ''),
                              // //   style: ElevatedButton.styleFrom(
                              // //     backgroundColor: AppColors.primaryBlue,
                              // //     foregroundColor: Colors.white,
                              // //     padding: const EdgeInsets.symmetric(
                              // //       horizontal: 16,
                              // //       vertical: 12,
                              // //     ),
                              // //   ),
                              // // ),
                            ],
                          ),
                        ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            // Header Row (Table Column Titles)
                            // if (AppStyles.isWebScreen(context))
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF2F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.0, horizontal: 25.0),
                                      child: Text('No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF607185))),
                                    ),
                                  ),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Task type',
                                      color: Color(0xFF607185)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Enquiry For ',
                                      color: Color(0xFF607185)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Status ',
                                      color: Color(0xFF607185)),
                                  Container(
                                    width: 40,
                                  )
                                ],
                              ),
                            ),
                            isLoadingData
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : ListView.builder(
                                    shrinkWrap:
                                        true, // To avoid scrolling issues when inside a parent widget
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable scrolling here, as parent scroll handles it
                                    itemCount: processFlowProvider
                                        .processFlowFilteredList
                                        .length, // Number of leads
                                    itemBuilder: (context, index) {
                                      ProcessFlowModel processModel =
                                          processFlowProvider
                                              .processFlowFilteredList[index];
                                      return Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF6F7F9),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          // Alternate row colors
                                          child:
                                              // AppStyles.isWebScreen(context) ?
                                              Row(
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
                                                  child: Text(
                                                      (index + 1).toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 1,
                                                data: InkWell(
                                                  onTap: (settingsProvider.menuIsEditMap[36] == 1)
                                                      ? () {
                                                          if (AppStyles.isWebScreen(
                                                              context)) {
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext
                                                                  context) {
                                                                return AlertDialog(
                                                                  backgroundColor:
                                                                      Colors.white,
                                                                  content: SizedBox(
                                                                    width: AppStyles
                                                                            .isWebScreen(
                                                                                context)
                                                                        ? MediaQuery.of(
                                                                                    context)
                                                                                .size
                                                                                .width /
                                                                            3
                                                                        : MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .width,
                                                                    height:
                                                                        MediaQuery.of(
                                                                                context)
                                                                            .size
                                                                            .height,
                                                                    child:
                                                                        ProcessFlowAddWidget(
                                                                      isEdit: true,
                                                                      processFlowModel:
                                                                          processModel
                                                                              .copyWith(),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (c) =>
                                                                    ProcessFlowAddWidget(
                                                                  isEdit: true,
                                                                  processFlowModel:
                                                                      processModel
                                                                          .copyWith(),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      : null,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFE9EDF1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width >
                                                            1700
                                                        ? Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                processModel
                                                                        .taskTypeName ??
                                                                    "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width:
                                                                      8), // Space between the text and back image
                                                              // Back image (after text)
                                                              Image.asset(
                                                                'assets/images/forward.png', // Replace with your image asset or NetworkImage
                                                                width:
                                                                    12, // Adjust the size of the image
                                                                height:
                                                                    12, // Adjust the size of the image
                                                              ),
                                                            ],
                                                          )
                                                        : Text(
                                                            processModel
                                                                    .taskTypeName ??
                                                                "",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title: processModel
                                                          .enquiryForName ??
                                                      ""),
                                              TableWidget(
                                                  flex: 1,
                                                  title:
                                                      processModel.statusName ??
                                                          ""),
                                              if (settingsProvider.menuIsDeleteMap[36] == 1)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Confirm Delete'),
                                                              content: const Text(
                                                                  'Are you sure you want to delete?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: const Text(
                                                                      'Cancel'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    await processFlowProvider.deleteProcessFlowById(
                                                                        context,
                                                                        processModel
                                                                            .flowId!);
                                                                    getData();
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Delete',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red),
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      )),
                                                )
                                            ],
                                          )
                                          //mobile design
                                          // : Padding(
                                          //     padding:
                                          //         const EdgeInsets.all(8.0),
                                          //     child: Column(
                                          //       // mainAxisAlignment: MainAxisAlignment.start,
                                          //       crossAxisAlignment:
                                          //           CrossAxisAlignment.start,
                                          //       children: [
                                          //         // SizedBox(
                                          //         //   width: 80,
                                          //         //   child: Padding(
                                          //         //     padding:
                                          //         //         const EdgeInsets.symmetric(
                                          //         //             vertical: 12.0,
                                          //         //             horizontal: 25.0),
                                          //         //     child: Text(
                                          //         //         ((index + 1) +
                                          //         //                 leadProvider
                                          //         //                     .startLimit -
                                          //         //                 1)
                                          //         //             .toString(),
                                          //         //         style: const TextStyle(
                                          //         //           fontWeight: FontWeight.bold,
                                          //         //         )),
                                          //         //   ),
                                          //         // ),
                                          //         Row(
                                          //           children: [
                                          //             InkWell(
                                          //               onTap: () {
                                          //                 showDialog(
                                          //                   context: context,
                                          //                   builder: (BuildContext context) {
                                          //                     return  ProcessFlowAddWidget(
                                          //                       isEdit: true,processFlowModel: processModel,
                                          //                     );
                                          //                   },
                                          //                 );
                                          //               },
                                          //               child: Container(
                                          //                 padding:
                                          //                     const EdgeInsets
                                          //                         .symmetric(
                                          //                         horizontal:
                                          //                             8,
                                          //                         vertical:
                                          //                             4),
                                          //                 decoration:
                                          //                     BoxDecoration(
                                          //                   color: const Color(
                                          //                       0xFFE9EDF1),
                                          //                   borderRadius:
                                          //                       BorderRadius
                                          //                           .circular(
                                          //                               50),
                                          //                 ),
                                          //                 constraints:
                                          //                     const BoxConstraints(
                                          //                   maxWidth:
                                          //                       120, // Set your desired max width here
                                          //                 ),
                                          //                 child: Text(
                                          //                   processModel
                                          //                           .taskTypeName ??
                                          //                       "",
                                          //                   overflow:
                                          //                       TextOverflow
                                          //                           .ellipsis,
                                          //                   maxLines: 1,
                                          //                   style:
                                          //                       const TextStyle(
                                          //                     color: Colors
                                          //                         .black,
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .bold,
                                          //                     fontSize: 14,
                                          //                   ),
                                          //                 ),
                                          //               ),
                                          //             ),
                                          //             Text(
                                          //               processModel
                                          //                       .statusName ??
                                          //                   "",
                                          //               style: const TextStyle(
                                          //                   fontWeight:
                                          //                       FontWeight
                                          //                           .w600),
                                          //             ),
                                          //           ],
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          );
                                    },
                                  ),
                            // if (leadProvider.leadData.isEmpty)
                            //   Container(
                            //     height: 400,
                            //     // child: Center(
                            //     //   child: Text(
                            //     //     "No Data",
                            //     //     style: TextStyle(fontWeight: FontWeight.w600),
                            //     //   ),
                            //     // ),
                            //   ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
