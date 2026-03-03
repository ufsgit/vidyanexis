import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class LeadDataPage extends StatefulWidget {
  final String source;
  final String fromDate;
  final String toDate;
  final int user;

  const LeadDataPage({
    super.key,
    required this.source,
    required this.fromDate,
    required this.toDate,
    required this.user,
  });

  @override
  State<LeadDataPage> createState() => _LeadDataPageState();
}

class _LeadDataPageState extends State<LeadDataPage> {
  bool _isLoading = true;
  List<SearchLeadModel> _leads = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchLeadDashboard,
        bodyData: {
          "lead_Name": "",
          "Is_Date": widget.fromDate.isNotEmpty ? "1" : "0",
          "Fromdate": widget.fromDate,
          "Todate": widget.toDate,
          "To_User_Id": widget.user.toString(),
          "Status_Id": "0",
          "Page_Index1": "0",
          "Page_Index2": "200",
          "Enquiry_For_Id": "0",
          "Enquiry_Source_Id": "0",
          "Source": widget.source,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          setState(() {
            _leads = data.map((e) => SearchLeadModel.fromJson(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from server';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load leads: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.source
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('$title ${_leads.isNotEmpty ? "(${_leads.length})" : ""}'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _leads.isEmpty
                  ? const Center(child: Text("No leads found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _leads.length,
                      itemBuilder: (context, index) {
                        final lead = _leads[index];
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${index + 1}. ${lead.customerName.isNotEmpty ? lead.customerName : 'Unknown Customer'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF152D70),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF152D70)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        lead.statusName.isNotEmpty
                                            ? lead.statusName
                                            : 'N/A',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF152D70),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      lead.contactNumber.isNotEmpty
                                          ? lead.contactNumber
                                          : 'No contact',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Assigned to: ${lead.toUserName.isNotEmpty ? lead.toUserName : "Unassigned"}',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                if (lead.remark.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Remark: ${lead.remark}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
