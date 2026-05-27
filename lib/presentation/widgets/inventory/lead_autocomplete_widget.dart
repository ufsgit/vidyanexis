import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/lead_customer_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class LeadAutocompleteWidget extends StatefulWidget {
  final void Function(LeadCustomerModel model) onSelected;
  final String? labelText;
  final String? initialValue;

  const LeadAutocompleteWidget({
    super.key,
    required this.onSelected,
    this.labelText,
    this.initialValue,
  });

  @override
  State<LeadAutocompleteWidget> createState() => _LeadAutocompleteWidgetState();
}

class _LeadAutocompleteWidgetState extends State<LeadAutocompleteWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.isEmpty) {
        _fetchLeads('');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchLeads(query);
    });
  }

  Future<void> _fetchLeads(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.searchLeadCustomerApi(query, context);
      // Trigger options refresh in RawAutocomplete safely
      _controller.value = _controller.value.copyWith();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return RawAutocomplete<LeadCustomerModel>(
          focusNode: _focusNode,
          textEditingController: _controller,
          optionsBuilder: (TextEditingValue textEditingValue) {
            final results = settingsProvider.searchLeadCustomer;
            if (results.isEmpty) {
              // Return a dummy item to ensure the dropdown opens
              return [
                LeadCustomerModel(
                  customerId: -1,
                  customerName: _isLoading ? 'Loading...' : 'Type to search...',
                  address: '',
                )
              ];
            }
            return results.take(10);
          },
          displayStringForOption: (LeadCustomerModel option) =>
              option.customerName,
          onSelected: (LeadCustomerModel selection) {
            if (selection.customerId == -1) {
              // If it's a dummy item, clear the text and don't trigger selection
              _controller.text = '';
              return;
            }
            widget.onSelected(selection);
            _controller.text = selection.customerName;
            _focusNode.unfocus();
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            return CustomTextfieldWidgetMobile(
              labelText: widget.labelText ?? 'Select Lead*',
              controller: textController,
              focusNode: focusNode,
              onChanged: _onSearchChanged,
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : const Icon(Icons.keyboard_arrow_down),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(4),
                child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    // Use a slightly larger pool for the reactive view
                    var currentOptions = settingsProvider.searchLeadCustomer;

                    if (currentOptions.isEmpty) {
                      currentOptions = [
                        LeadCustomerModel(
                          customerId: -1,
                          customerName:
                              _isLoading ? 'Loading...' : 'No results found',
                          address: '',
                        )
                      ];
                    }

                    final displayList = currentOptions.take(10).toList();

                    return Container(
                      width: MediaQuery.of(context).size.width - 64,
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: displayList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final LeadCustomerModel option = displayList[index];
                          final isDummy = option.customerId == -1;

                          return InkWell(
                            onTap: isDummy ? null : () => onSelected(option),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.customerName,
                                    style: TextStyle(
                                      fontWeight: isDummy
                                          ? FontWeight.normal
                                          : FontWeight.w500,
                                      fontSize: 14,
                                      color: isDummy
                                          ? Colors.grey
                                          : Colors.black87,
                                      fontStyle: isDummy
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                  ),
                                  if (!isDummy && option.address.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      option.address,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
