import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/process_flow_model.dart';
import 'package:vidyanexis/controller/process_flow_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_add_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

class ProcessFlowPage extends StatefulWidget {
  const ProcessFlowPage({super.key});

  @override
  State<ProcessFlowPage> createState() => _ProcessFlowPageState();
}

class _ProcessFlowPageState extends State<ProcessFlowPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  late ProcessFlowProvider processFlowProvider;
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
    if (!mounted) return;
    setState(() => isLoadingData = true);
    await processFlowProvider.getProcessFlow(context);
    
    if (searchController.text.isNotEmpty) {
      processFlowProvider.filterData(searchController.text);
    }
    
    if (!mounted) return;
    setState(() => isLoadingData = false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !AppStyles.isWebScreen(context);
    
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: isMobile ? const SidebarDrawer() : null,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isMobile),
            if (isMobile) _buildSearchBar(isHeader: false),
            Expanded(
              child: Consumer<ProcessFlowProvider>(
                builder: (context, provider, child) {
                  if (isLoadingData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.processFlowFilteredList.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: provider.processFlowFilteredList.length,
                    itemBuilder: (context, index) {
                      return _buildProcessFlowCard(
                        provider.processFlowFilteredList[index],
                        index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.sort_rounded,
                    size: 20,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
            ),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Builder(
                builder: (context) => IconButton(
                  onPressed: () {
                    ScaffoldState? parent;
                    context.visitAncestorElements((element) {
                      if (element is StatefulElement && element.state is ScaffoldState) {
                        ScaffoldState scaffold = element.state as ScaffoldState;
                        if (scaffold.hasDrawer) {
                          parent = scaffold;
                          return false;
                        }
                      }
                      return true;
                    });
                    parent?.openDrawer();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.sort_rounded,
                      size: 20,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                ),
              ),
            ),
          Text(
            'Process Flow',
            style: GoogleFonts.plusJakartaSans(
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlue800,
            ),
          ),
          const Spacer(),
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: _buildSearchBar(isHeader: true),
            ),
          if (settingsProvider.menuIsSaveMap[36] == 1)
            _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () => _openAddDialog(isEdit: false, model: ProcessFlowModel()),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.secondaryBlue,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryBlue.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildSearchBar({bool isHeader = false}) {
    Widget searchBar = Container(
      height: isHeader ? 44 : 50,
      width: isHeader ? 300 : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isHeader ? 12 : 16),
        border: isHeader ? Border.all(color: const Color(0xFFF1F5F9)) : null,
        boxShadow: isHeader ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (query) => processFlowProvider.filterData(query),
        decoration: InputDecoration(
          hintText: 'Search process flows...',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: isHeader ? 20 : 24),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isHeader ? 10 : 12),
        ),
      ),
    );

    if (!isHeader) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: searchBar,
      );
    }
    return searchBar;
  }

  Widget _buildProcessFlowCard(ProcessFlowModel model, int index) {
    final isWeb = AppStyles.isWebScreen(context);
    final double rowHeight = isWeb ? 36.0 : 48.0;

    return Container(
      height: rowHeight,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: settingsProvider.menuIsEditMap[36] == 1
              ? () => _openAddDialog(isEdit: true, model: model.copyWith())
              : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: isWeb ? 26 : 32,
                  height: isWeb ? 26 : 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: isWeb ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    model.taskTypeName ?? 'Unnamed Task',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isWeb ? 13 : 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlue800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          model.enquiryForName ?? 'N/A',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isWeb ? 12 : 13,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(model.statusName ?? 'Unknown', isWeb),
                const SizedBox(width: 12),
                if (settingsProvider.menuIsDeleteMap[36] == 1)
                  InkWell(
                    onTap: () => _confirmDelete(model),
                    child: Container(
                      padding: EdgeInsets.all(isWeb ? 4.0 : 6.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: const Color(0xFFEF4444),
                        size: isWeb ? 15 : 18,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isWeb) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Completed':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        break;
      case 'In Progress':
        bgColor = const Color(0xFFFEF9C3);
        textColor = const Color(0xFF854D0E);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 8 : 10, vertical: isWeb ? 2 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: isWeb ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No process flows found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddDialog({required bool isEdit, required ProcessFlowModel model}) {
    if (AppStyles.isWebScreen(context)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 1.5,
            height: MediaQuery.of(context).size.height,
            child: ProcessFlowAddWidget(
              isEdit: isEdit,
              processFlowModel: model,
            ),
          ),
        ),
      ).then((_) => getData());
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessFlowAddWidget(
            isEdit: isEdit,
            processFlowModel: model,
          ),
        ),
      ).then((_) => getData());
    }
  }

  void _confirmDelete(ProcessFlowModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete this process flow?',
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: const Color(0xFF64748B)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await processFlowProvider.deleteProcessFlowById(context, model.flowId!);
              getData();
            },
            child: Text(
              'Delete',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
