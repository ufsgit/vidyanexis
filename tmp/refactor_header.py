import re

def main():
    file_path = 'd:/dev/vidyanexis/lib/presentation/widgets/home/new_drawer_widget.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add state variables
    state_vars_str = """  // late CustomFieldWidgetBuilder widgetBuilder;
  final _formKey = GlobalKey<FormState>();"""
    
    new_state_vars = """  // late CustomFieldWidgetBuilder widgetBuilder;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _basicDetailsKey = GlobalKey();
  final GlobalKey _addressKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();"""

    content = content.replace(state_vars_str, new_state_vars)

    # 2. Key assignments
    # Add key to basic details ExpansionTile
    basic_details_str = """                      //basic
                      ExpansionTile(
                        shape: const RoundedRectangleBorder("""
    new_basic_details_str = """                      //basic
                      ExpansionTile(
                        key: _basicDetailsKey,
                        shape: const RoundedRectangleBorder("""
    content = content.replace(basic_details_str, new_basic_details_str)

    # Add key to address ExpansionTile
    address_str = """                      //address
                      ExpansionTile(
                        shape: const RoundedRectangleBorder("""
    new_address_str = """                      //address
                      ExpansionTile(
                        key: _addressKey,
                        shape: const RoundedRectangleBorder("""
    content = content.replace(address_str, new_address_str)


    # 3. Restructure header out of the ListView and use GestureDetectors
    # The header starts at:
    #                 Expanded(
    #                   child: ListView(
    #                     padding: const EdgeInsets.all(16.0),
    #                     children: [
    #                       // Copy all your existing ExpansionTile widgets here
    #                       // (Basic details, Address, Invertor and Panel Details, etc.)
    # 
    #                       Container(
    #                         padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
    # ... up to ...
    #                             ),
    #                           ],
    #                         ),
    #                       ),
    #                       const SizedBox(height: 16),
    #                       //basic
    
    # We will just locate the whole header container from top to bottom
    old_layout_str = """                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Copy all your existing ExpansionTile widgets here
                      // (Basic details, Address, Invertor and Panel Details, etc.)

                      Container(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close, color: AppColors.textGrey3),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          _onDrawerClosed(context);
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Image.asset(AppStyles.logo(), width: 24, height: 24, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.red, size: 24)),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.isEdit ? 'Edit Lead details' : 'Add New Lead',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.textBlack,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (!widget.isEdit)
                                            Text(
                                              '${leadProvider.loginBranchName} | ${leadProvider.loginDepartmentName}',
                                              style: GoogleFonts.plusJakartaSans(
                                                color: AppColors.primaryBlue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: _saveLead,
                                    child: Text(
                                      'Save',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.primaryBlue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Basic Details / Address Toggle Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    'Basic details',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textBlack,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    'Address',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      //basic"""
    
    new_layout_str = """                Container(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: AppColors.textGrey3),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _onDrawerClosed(context);
                                  },
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Image.asset(AppStyles.logo(), width: 24, height: 24, errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.red, size: 24)),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.isEdit ? 'Edit Lead details' : 'Add New Lead',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textBlack,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (!widget.isEdit)
                                      Text(
                                        '${leadProvider.loginBranchName} | ${leadProvider.loginDepartmentName}',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _saveLead,
                              child: Text(
                                'Save',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Basic Details / Address Toggle Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_basicDetailsKey.currentContext != null) {
                                Scrollable.ensureVisible(
                                  _basicDetailsKey.currentContext!,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5)),
                              ),
                              child: Text(
                                'Basic details',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.textBlack,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (_addressKey.currentContext != null) {
                                Scrollable.ensureVisible(
                                  _addressKey.currentContext!,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Address',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: [
                      //basic"""
    
    if old_layout_str not in content:
        print("Error: Could not find layout string to replace.")
        return
        
    content = content.replace(old_layout_str, new_layout_str)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print("Successfully replaced layout.")

if __name__ == '__main__':
    main()
