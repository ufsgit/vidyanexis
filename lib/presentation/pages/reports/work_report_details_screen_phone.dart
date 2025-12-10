// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:techtify/main.dart';
// import 'package:provider/provider.dart';
// import 'package:techtify/constants/app_colors.dart';
// import 'package:techtify/controller/customer_provider.dart';
// import 'package:techtify/controller/leads_provider.dart';
// import 'package:techtify/controller/side_bar_provider.dart';
// import 'package:techtify/presentation/pages/reports/work_report_screen_phone.dart';
// import 'package:techtify/presentation/pages/reports/work_summary_screen_phone.dart';
// import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
// import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';

// class WorkReportDetailsScreenPhone extends StatefulWidget {
//   final String userId;
//   final String userName;
//   const WorkReportDetailsScreenPhone({
//     super.key,
//     required this.userId,
//     required this.userName,
//   });

//   @override
//   State<WorkReportDetailsScreenPhone> createState() =>
//       _WorkReportDetailsScreenPhoneState();
// }

// class _WorkReportDetailsScreenPhoneState
//     extends State<WorkReportDetailsScreenPhone> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController searchController = TextEditingController();
//   final searchProvider = Provider.of<SidebarProvider>(navigatorKey.currentState!.context);

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     searchProvider.stopSearch();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final searchProvider = Provider.of<SidebarProvider>(context);
//     final customerProvider = Provider.of<CustomerProvider>(context);
//     final leadProvider = Provider.of<LeadsProvider>(context);
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.white,
//       appBar: CustomAppBar(
//         leadingWidth: 40,
//         leadingWidget: Container(
//           alignment: Alignment.centerLeft,
//           padding: const EdgeInsets.only(left: 8),
//           child: IconButton(
//             onPressed: () {
//               searchProvider.stopSearch();
//               customerProvider.setFilter(false);
//               leadProvider.setFilter(false);
//               context.pop();
//             },
//             icon: Icon(
//               Icons.arrow_back,
//               color: AppColors.textGrey4,
//             ),
//             iconSize: 24,
//           ),
//         ),
//         title: 'Daniel Foster',
//         showFilterIcon: false,
//         titleStyle: GoogleFonts.plusJakartaSans(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textBlack),
//         searchHintText: 'Search Reports...',
//         onFilterTap: () {},
//         onSearchTap: () {
//           searchProvider.startSearch();
//         },
//         onClearTap: () {
//           searchController.clear();
//           searchProvider.stopSearch();
//         },
//         onSearch: (query) {},
//         searchController: searchController,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(
//               height: 16,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: InkWell(
//                 onTap: () {},
//                 child: Row(
//                   children: [
//                     Container(
//                       height: 28,
//                       decoration: BoxDecoration(
//                           color: AppColors.scaffoldColor,
//                           borderRadius: BorderRadius.circular(8)),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                         ),
//                         child: Row(
//                           children: [
//                             CustomText(
//                               '28 May 2024 - 28 May 2024',
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textBlack,
//                             ),
//                             Icon(
//                               Icons.keyboard_arrow_down_rounded,
//                               color: AppColors.textGrey4,
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: InkWell(
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(
//                     builder: (context) {
//                       return WorkReportPhone(
//                         userId: widget.userId,
//                         userName: widget.userName,
//                       );
//                     },
//                   ));
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       color: Color(0xFFF2F7FF),
//                       borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 10),
//                     child: Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CustomText(
//                               "Total Follow ups",
//                               fontWeight: FontWeight.w500,
//                               fontSize: 12,
//                               color: AppColors.textBlack,
//                             ),
//                             CustomText(
//                               "₹${43}",
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.bluebutton,
//                               fontSize: 16,
//                             ),
//                           ],
//                         ),
//                         const Spacer(),
//                         Transform.rotate(
//                           angle: 4.7,
//                           child: Image.asset(
//                             "assets/icons/arrow_down_icon.png",
//                             width: 22,
//                             height: 22,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(
//               height: 16,
//             ),
//             ListView.builder(
//               itemCount: 4,
//               shrinkWrap: true,
//               physics: const ClampingScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return InkWell(
//                   onTap: () {},
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: 4,
//                               height: 20,
//                               decoration: BoxDecoration(
//                                 color: AppColors.appViolet,
//                                 borderRadius: BorderRadius.circular(100),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                                 child: CustomText(
//                               'Converted',
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textBlack,
//                             )),
//                             const SizedBox(width: 8),
//                             Text(
//                               '177',
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: GoogleFonts.plusJakartaSans(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: AppColors.textBlack),
//                             ),
//                             const SizedBox(width: 8),
//                             Transform.rotate(
//                               angle: 4.7,
//                               child: Image.asset(
//                                 "assets/icons/arrow_down_icon.png",
//                                 width: 22,
//                                 height: 22,
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                       Divider(
//                         height: 2,
//                         color: AppColors.grey,
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
