import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/purchase_order.dart';
import '../../domain/entities/purchase_quotation.dart';
import '../providers/purchase_quotation_providers.dart';

class PurchaseOrderFormDialog extends ConsumerStatefulWidget {
  const PurchaseOrderFormDialog({
    super.key,
    required this.projectId,
    this.order,
  });

  final String projectId;
  final PurchaseOrder? order;

  bool get isEditing => order != null;

  @override
  ConsumerState<PurchaseOrderFormDialog> createState() =>
      _PurchaseOrderFormDialogState();
}

class _PurchaseOrderFormDialogState
    extends ConsumerState<PurchaseOrderFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _supplierIdController;
  late final TextEditingController _poNumberController;
  late final TextEditingController _subtotalController;
  late final TextEditingController _taxController;
  late final TextEditingController _discountController;
  late final TextEditingController _deliveryChargesController;
  late final TextEditingController _paymentTermsController;
  late final TextEditingController _deliveryTermsController;
  late final TextEditingController _notesController;

  late DateTime _orderDate;
  DateTime? _expectedDeliveryDate;
  late PurchaseOrderStatus _status;

  String? _purchaseQuotationId;

  @override
  void initState() {
    super.initState();

    final order = widget.order;

    _supplierIdController = TextEditingController(
      text: order?.supplierId ?? '',
    );

    _poNumberController = TextEditingController(
      text: order?.poNumber ?? '',
    );

    _subtotalController = TextEditingController(
      text: order == null ? '' : order.subtotal.toString(),
    );

    _taxController = TextEditingController(
      text: order == null ? '' : order.tax.toString(),
    );

    _discountController = TextEditingController(
      text: order == null ? '0' : order.discount.toString(),
    );

    _deliveryChargesController = TextEditingController(
      text: order == null
          ? '0'
          : order.deliveryCharges.toString(),
    );

    _paymentTermsController = TextEditingController(
      text: order?.paymentTerms ?? '',
    );

    _deliveryTermsController = TextEditingController(
      text: order?.deliveryTerms ?? '',
    );

    _notesController = TextEditingController(
      text: order?.notes ?? '',
    );

    _orderDate = order?.orderDate ?? DateTime.now();
    _expectedDeliveryDate = order?.expectedDeliveryDate;
    _status = order?.status ?? PurchaseOrderStatus.draft;

    _purchaseQuotationId = order?.purchaseQuotationId;
  }

  @override
  void dispose() {
    _supplierIdController.dispose();
    _poNumberController.dispose();
    _subtotalController.dispose();
    _taxController.dispose();
    _discountController.dispose();
    _deliveryChargesController.dispose();
    _paymentTermsController.dispose();
    _deliveryTermsController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotationsAsync = ref.watch(
      purchaseQuotationsProvider(widget.projectId),
    );

    return AlertDialog(
      title: Text(
        widget.isEditing
            ? 'Edit Purchase Order'
            : 'Add Purchase Order',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _supplierIdController,
                  label: 'Supplier ID',
                  hint: 'Example: supplier-001',
                  validator: _requiredValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _buildQuotationDropdown(
                  quotationsAsync,
                ),

                const SizedBox(
                  height: AppSpacing.sm,
                ),

                _buildTextField(
                  controller: _poNumberController,
                  label: 'PO Number',
                  hint: 'Example: PO-2026-004',
                  validator: _requiredValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildDateField(
                  context: context,
                  label: 'Order Date',
                  date: _orderDate,
                  onTap: _selectOrderDate,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildDateField(
                  context: context,
                  label: 'Expected Delivery',
                  date: _expectedDeliveryDate,
                  onTap: _selectExpectedDeliveryDate,
                  allowClear: true,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                DropdownButtonFormField<PurchaseOrderStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: PurchaseOrderStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            _statusLabel(status),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _subtotalController,
                  label: 'Subtotal',
                  validator: _numberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _taxController,
                  label: 'Tax',
                  validator: _numberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _discountController,
                  label: 'Discount',
                  validator: _numberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildNumberField(
                  controller: _deliveryChargesController,
                  label: 'Delivery Charges',
                  validator: _numberValidator,
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _paymentTermsController,
                  label: 'Payment Terms',
                  hint: 'Example: 30 days credit',
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _deliveryTermsController,
                  label: 'Delivery Terms',
                  hint: 'Example: Delivery within 3 days',
                ),
                const SizedBox(
                  height: AppSpacing.sm,
                ),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.isEditing
                ? 'Save Changes'
                : 'Add Order',
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationDropdown(
    AsyncValue<List<PurchaseQuotation>> quotationsAsync,
  ) {
    return quotationsAsync.when(
      loading: () => const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Purchase Quotation',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(
              width: AppSpacing.sm,
            ),
            Text('Loading quotations...'),
          ],
        ),
      ),
      error: (_, _) => InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Purchase Quotation',
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Unable to load quotations',
              ),
            ),
            IconButton(
              tooltip: 'Retry',
              onPressed: () {
                ref.invalidate(
                  purchaseQuotationsProvider(
                    widget.projectId,
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh,
              ),
            ),
          ],
        ),
      ),
      data: (quotations) {
        final activeQuotations = quotations
            .where(
              (quotation) => !quotation.isArchived,
            )
            .toList();

        final selectedExists = activeQuotations.any(
          (quotation) =>
              quotation.id == _purchaseQuotationId,
        );

        final selectedValue =
            selectedExists ? _purchaseQuotationId : null;

        return DropdownButtonFormField<String?>(
          initialValue: selectedValue,
          decoration: const InputDecoration(
            labelText: 'Purchase Quotation',
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No quotation'),
            ),
            ...activeQuotations.map(
              (quotation) => DropdownMenuItem<String?>(
                value: quotation.id,
                child: Text(
                  '${quotation.quotationNumber} — '
                  '${_statusLabelForQuotation(quotation.status)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _purchaseQuotationId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: '₹ ',
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool allowClear = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: allowClear && date != null
              ? IconButton(
                  tooltip: 'Clear',
                  onPressed: () {
                    setState(() {
                      _expectedDeliveryDate = null;
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
              : const Icon(
                  Icons.calendar_today_outlined,
                ),
        ),
        child: Text(
          date == null
              ? 'Not specified'
              : _formatDate(date),
        ),
      ),
    );
  }

  Future<void> _selectOrderDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _orderDate = selected;
    });
  }

  Future<void> _selectExpectedDeliveryDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          _expectedDeliveryDate ?? _orderDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _expectedDeliveryDate = selected;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final order = PurchaseOrder(
      id: widget.order?.id ??
          'purchase-order-'
              '${DateTime.now().microsecondsSinceEpoch}',
      projectId:
          widget.order?.projectId ?? widget.projectId,
      supplierId:
          _supplierIdController.text.trim(),
      purchaseQuotationId:
          _purchaseQuotationId,
      poNumber:
          _poNumberController.text.trim(),
      orderDate: _orderDate,
      expectedDeliveryDate:
          _expectedDeliveryDate,
      subtotal:
          double.parse(_subtotalController.text),
      tax:
          double.parse(_taxController.text),
      discount:
          double.parse(_discountController.text),
      deliveryCharges:
          double.parse(
        _deliveryChargesController.text,
      ),
      paymentTerms:
          _optionalValue(
        _paymentTermsController.text,
      ),
      deliveryTerms:
          _optionalValue(
        _deliveryTermsController.text,
      ),
      notes:
          _optionalValue(
        _notesController.text,
      ),
      status: _status,
      isArchived:
          widget.order?.isArchived ?? false,
    );

    Navigator.of(context).pop(order);
  }

  String? _requiredValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Enter an amount';
    }

    final number = double.tryParse(
      value.trim(),
    );

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _statusLabel(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.draft:
        return 'Draft';
      case PurchaseOrderStatus.issued:
        return 'Issued';
      case PurchaseOrderStatus.partiallyReceived:
        return 'Partially Received';
      case PurchaseOrderStatus.received:
        return 'Received';
      case PurchaseOrderStatus.cancelled:
        return 'Cancelled';
      case PurchaseOrderStatus.closed:
        return 'Closed';
    }
  }

  String _statusLabelForQuotation(
    PurchaseQuotationStatus status,
  ) {
    switch (status) {
      case PurchaseQuotationStatus.draft:
        return 'Draft';
      case PurchaseQuotationStatus.received:
        return 'Received';
      case PurchaseQuotationStatus.underReview:
        return 'Under Review';
      case PurchaseQuotationStatus.accepted:
        return 'Accepted';
      case PurchaseQuotationStatus.rejected:
        return 'Rejected';
      case PurchaseQuotationStatus.expired:
        return 'Expired';
    }
  }
}
