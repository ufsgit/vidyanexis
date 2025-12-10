import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/models/get_user_model.dart';
import 'package:techtify/controller/models/sub_user_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';

class AssignTeamWidget extends StatefulWidget {
  const AssignTeamWidget({super.key, required this.userModel});
  final GetUserModel userModel;

  @override
  _AssignTeamWidgetState createState() => _AssignTeamWidgetState();
}

class _AssignTeamWidgetState extends State<AssignTeamWidget> {
  bool _selectAll = false;
  List<bool> _selectedUsers = [];
  Set<int> _preSelectedUserIds = {};

  List<Map<String, dynamic>> _getSelectedUsers() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    List<Map<String, dynamic>> selectedUsers = [];

    for (int i = 0; i < _selectedUsers.length; i++) {
      if (_selectedUsers[i]) {
        final user = settingsProvider.searchUserDetails[i];
        selectedUsers.add({
          'User_Selection_Id': user.userDetailsId,
          'User_Selection_Name': user.userDetailsName,
        });
      }
    }
    return selectedUsers;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider
          .getSubUsers(widget.userModel.userDetailsId.toString(), context,
              onSubUsersLoaded: (List<SubUsersDatum> subUsers) {
        setState(() {
          _preSelectedUserIds =
              subUsers.map((user) => user.userSelectionId).toSet();
          _selectedUsers =
              List.generate(settingsProvider.searchUserDetails.length, (index) {
            final currentUser = settingsProvider.searchUserDetails[index];
            return _preSelectedUserIds.contains(currentUser.userDetailsId);
          });
          _selectAll = _selectedUsers.every((selected) => selected);
        });
      });
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      _selectedUsers = _selectedUsers.map(((_) => _selectAll)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width:
                constraints.maxWidth > 600 ? 800 : constraints.maxWidth * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Team of ${widget.userModel.userDetailsName}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table Header
                if (constraints.maxWidth > 600)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 48, child: Center(child: Text('No.'))),
                        const Expanded(child: Text('User')),
                        SizedBox(
                          width: 48,
                          child: Center(
                            child: Checkbox(
                              value: _selectAll,
                              onChanged: (value) => _toggleSelectAll(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // List of users - only build if we have data
                if (settingsProvider.searchUserDetails.isNotEmpty)
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: settingsProvider.searchUserDetails.length,
                      itemBuilder: (context, index) {
                        // Ensure _selectedUsers is the same length as searchUserDetails
                        if (_selectedUsers.length <
                            settingsProvider.searchUserDetails.length) {
                          _selectedUsers.add(false);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 48,
                                  child: Center(child: Text('${index + 1}'))),
                              Expanded(
                                  child: Text(settingsProvider
                                      .searchUserDetails[index]
                                      .userDetailsName)),
                              Checkbox(
                                value: _selectedUsers[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedUsers[index] = value ?? false;

                                    // Update select all status
                                    _selectAll = _selectedUsers
                                        .every((selected) => selected);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      isLoading: settingsProvider.isSavingTeam,
                      onPressed: () async {
                        final selectedUsers = _getSelectedUsers();
                        await settingsProvider.addSubUserDetails(
                          context: context,
                          userDetailsId:
                              widget.userModel.userDetailsId.toString(),
                          subUsers: selectedUsers,
                        );
                      },
                      backgroundColor: AppColors.bluebutton,
                      borderColor: Colors.transparent,
                      textColor: Colors.white,
                      buttonText: 'Save',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
