import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:vidyanexis/controller/job_sheet_provider.dart';

class SignatureUploadPage extends StatelessWidget {
  final bool customerSignature;

  const SignatureUploadPage({Key? key, required this.customerSignature})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<JobSheetProvider>(context, listen: false);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(customerSignature ? 'Customer Signature' : 'Technician Signature', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                provider.signatureController.clear();
                Navigator.pop(context);
              }
            )
          ]
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: Signature(
            controller: provider.signatureController,
            height: 250,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton(
              onPressed: () => provider.signatureController.clear(),
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                if (customerSignature) {
                  provider.saveCustomerSignature(context);
                } else {
                  provider.saveTechnicianSignature(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        )
      ],
    );
  }
}
