import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/get_refund_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_refund.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class RefundCard extends StatelessWidget {
  final RefundModel refundModel;
  final String customerId;
  const RefundCard({
    super.key,
    required this.refundModel,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    if (refundModel.data == null || refundModel.data!.isEmpty) {
      return const SizedBox.shrink();
    }

    final refund = refundModel.data![0];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Refund ID and Actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refund ID: ${refund.refundId ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By: ${refund.byUserName ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (settingsprovider.menuIsEditMap[71] == 1)
                  IconButton(
                    onPressed: () {
                      try {
                        // Populate controllers with refund data
                        customerDetailsProvider.electricalsectioncontroller
                            .text = refund.electricalSection ?? '';
                        customerDetailsProvider.electricalsectionplacecontroller
                            .text = refund.place ?? '';
                        customerDetailsProvider.consumernumbercontroller.text =
                            refund.consumerNumber ?? '';
                        customerDetailsProvider.kwcapacitycontroller.text =
                            refund.kwCapacity ?? '';
                        customerDetailsProvider.accountnamecontroller.text =
                            refund.accountHolderName ?? '';
                        customerDetailsProvider.accountnumbercontroller.text =
                            refund.accountNumber ?? '';
                        customerDetailsProvider.banknamecontroller.text =
                            refund.bankName ?? '';
                        customerDetailsProvider.ifsccontroller.text =
                            refund.ifscCode ?? '';

                        if (context.mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return RefundCreationWidget(
                                recieptId: refund.refundId ?? '0',
                                isEdit: true,
                                customerId: customerId,
                              );
                            },
                          );
                        }
                      } catch (e) {
                        print('Error opening refund edit dialog: $e');
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (settingsprovider.menuIsDeleteMap[71] == 1)
                  IconButton(
                    onPressed: () {
                      try {
                        if (context.mounted) {
                          showConfirmationDialog(
                            isLoading: customerDetailsProvider.isDeleteLoading,
                            context: context,
                            title: 'Confirm Deletion',
                            content:
                                'Are you sure you want to delete this Refund?',
                            onCancel: () {
                              try {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                print('Error closing dialog: $e');
                              }
                            },
                            onConfirm: () {
                              try {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                print('Error closing dialog: $e');
                              }
                            },
                            confirmButtonText: 'Delete',
                            confirmButtonColor: Colors.red,
                          );
                        }
                      } catch (e) {
                        print('Error opening confirmation dialog: $e');
                      }
                    },
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.textRed,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            // Basic Details Section
            Text(
              'Basic Details',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Electrical Section', refund.electricalSection),
            _buildDetailRow('Place', refund.place),
            _buildDetailRow('Consumer Number', refund.consumerNumber),
            _buildDetailRow('KW Capacity', refund.kwCapacity),
            const SizedBox(height: 12),
            // Account Details Section
            Text(
              'Account Details',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Account Holder', refund.accountHolderName),
            _buildDetailRow('Account Number', refund.accountNumber),
            _buildDetailRow('Bank Name', refund.bankName),
            _buildDetailRow('IFSC Code', refund.ifscCode),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
