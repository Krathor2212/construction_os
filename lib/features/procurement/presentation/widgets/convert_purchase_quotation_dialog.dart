import 'package:flutter/material.dart';

class ConvertPurchaseQuotationDialog extends StatefulWidget {
  const ConvertPurchaseQuotationDialog({
    super.key,
    required this.defaultPoNumber,
  });

  final String defaultPoNumber;

  @override
  State<ConvertPurchaseQuotationDialog> createState() =>
      _ConvertPurchaseQuotationDialogState();
}

class _ConvertPurchaseQuotationDialogState
    extends State<ConvertPurchaseQuotationDialog> {
  late final TextEditingController _poNumberController;
  late DateTime _orderDate;
  DateTime? _expectedDeliveryDate;

  @override
  void initState() {
    super.initState();

    _poNumberController = TextEditingController(
      text: widget.defaultPoNumber,
    );

    _orderDate = DateTime.now();
  }

  @override
  void dispose() {
    _poNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectOrderDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _orderDate = selectedDate;
    });
  }

  Future<void> _selectExpectedDeliveryDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expectedDeliveryDate ?? _orderDate,
      firstDate: _orderDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _expectedDeliveryDate = selectedDate;
    });
  }

  void _submit() {
    final poNumber = _poNumberController.text.trim();

    if (poNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PO number is required.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      ConvertPurchaseQuotationResult(
        poNumber: poNumber,
        orderDate: _orderDate,
        expectedDeliveryDate: _expectedDeliveryDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Convert to Purchase Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _poNumberController,
              decoration: const InputDecoration(
                labelText: 'PO Number',
                hintText: 'Enter purchase order number',
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Order Date'),
              subtitle: Text(
                MaterialLocalizations.of(context).formatMediumDate(
                  _orderDate,
                ),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _selectOrderDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expected Delivery'),
              subtitle: Text(
                _expectedDeliveryDate == null
                    ? 'Not specified'
                    : MaterialLocalizations.of(context).formatMediumDate(
                        _expectedDeliveryDate!,
                      ),
              ),
              trailing: const Icon(Icons.local_shipping_outlined),
              onTap: _selectExpectedDeliveryDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Convert'),
        ),
      ],
    );
  }
}

class ConvertPurchaseQuotationResult {
  const ConvertPurchaseQuotationResult({
    required this.poNumber,
    required this.orderDate,
    required this.expectedDeliveryDate,
  });

  final String poNumber;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
}