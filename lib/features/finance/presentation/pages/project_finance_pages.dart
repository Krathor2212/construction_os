import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/client_invoice.dart';
import '../../domain/entities/supplier_bill.dart';
import '../../domain/entities/supplier_payment.dart';
import '../providers/finance_providers.dart';

class ProjectSupplierBillsPage extends ConsumerWidget {
  const ProjectSupplierBillsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(projectSupplierBillsProvider(projectId));
    return _FinanceScaffold(
      title: 'Supplier Bills',
      actionLabel: 'Add bill',
      onAdd: () => _addBill(context, ref),
      body: bills.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load bills: $error')),
        data: (items) => _FinanceList(
          emptyText: 'No supplier bills recorded yet.',
          children: items
              .map(
                (bill) => ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: Text('${bill.billNumber} • ${bill.supplierName}'),
                  subtitle: Text(
                    '${_date(bill.billDate)} • ${_status(bill.status)}\n'
                    'Outstanding: ${bill.outstandingAmount.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: Text(bill.amount.toStringAsFixed(2)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _addBill(BuildContext context, WidgetRef ref) async {
    final bill = await showDialog<SupplierBill>(
      context: context,
      builder: (_) => _SupplierBillDialog(projectId: projectId),
    );
    if (bill == null || !context.mounted) return;
    await ref.read(financeActionsProvider).createBill(bill);
  }
}

class ProjectSupplierPaymentsPage extends ConsumerWidget {
  const ProjectSupplierPaymentsPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(projectSupplierPaymentsProvider(projectId));
    return _FinanceScaffold(
      title: 'Supplier Payments',
      actionLabel: 'Record payment',
      onAdd: () => _addPayment(context, ref),
      body: payments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load payments: $error')),
        data: (items) => _FinanceList(
          emptyText: 'No supplier payments recorded yet.',
          children: items
              .map(
                (payment) => ListTile(
                  leading: const Icon(Icons.payments_outlined),
                  title: Text('${payment.supplierName} • ${payment.reference}'),
                  subtitle: Text(
                    '${_date(payment.paymentDate)} • ${payment.paymentMethod}\n'
                    'Bill: ${payment.supplierBillId}',
                  ),
                  isThreeLine: true,
                  trailing: Text(payment.amount.toStringAsFixed(2)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _addPayment(BuildContext context, WidgetRef ref) async {
    final payment = await showDialog<SupplierPayment>(
      context: context,
      builder: (_) => _SupplierPaymentDialog(projectId: projectId),
    );
    if (payment == null || !context.mounted) return;
    await ref.read(financeActionsProvider).createPayment(payment);
  }
}

class ProjectClientInvoicesPage extends ConsumerWidget {
  const ProjectClientInvoicesPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(projectClientInvoicesProvider(projectId));
    return _FinanceScaffold(
      title: 'Client Invoices & Milestones',
      actionLabel: 'Add invoice',
      onAdd: () => _addInvoice(context, ref),
      body: invoices.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load invoices: $error')),
        data: (items) => _FinanceList(
          emptyText: 'No client invoices recorded yet.',
          children: items
              .map(
                (invoice) => ListTile(
                  leading: const Icon(Icons.request_quote_outlined),
                  title: Text(
                    '${invoice.invoiceNumber} • ${invoice.milestoneName}',
                  ),
                  subtitle: Text(
                    '${_date(invoice.issueDate)} • ${_status(invoice.status)}\n'
                    'Outstanding: ${invoice.outstandingAmount.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: Text(invoice.amount.toStringAsFixed(2)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _addInvoice(BuildContext context, WidgetRef ref) async {
    final invoice = await showDialog<ClientInvoice>(
      context: context,
      builder: (_) => _ClientInvoiceDialog(projectId: projectId),
    );
    if (invoice == null || !context.mounted) return;
    await ref.read(financeActionsProvider).createInvoice(invoice);
  }
}

class _FinanceScaffold extends StatelessWidget {
  const _FinanceScaffold({
    required this.title,
    required this.actionLabel,
    required this.onAdd,
    required this.body,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAdd;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: Text(actionLabel),
      ),
    );
  }
}

class _FinanceList extends StatelessWidget {
  const _FinanceList({required this.emptyText, required this.children});

  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return Center(child: Text(emptyText));
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, index) => Card(child: children[index]),
    );
  }
}

class _SupplierBillDialog extends _SimpleFinanceDialog<SupplierBill> {
  const _SupplierBillDialog({required super.projectId});

  @override
  String get title => 'Add supplier bill';

  @override
  String get firstLabel => 'Supplier name';

  @override
  String get secondLabel => 'Bill number';

  @override
  SupplierBill buildEntity(
    String id,
    String first,
    String second,
    double amount,
  ) {
    final now = DateTime.now();
    return SupplierBill(
      id: id,
      projectId: projectId,
      supplierName: first,
      billNumber: second,
      billDate: now,
      dueDate: now.add(const Duration(days: 30)),
      amount: amount,
      status: SupplierBillStatus.submitted,
    );
  }
}

class _SupplierPaymentDialog extends _SimpleFinanceDialog<SupplierPayment> {
  const _SupplierPaymentDialog({required super.projectId});

  @override
  String get title => 'Record supplier payment';

  @override
  String get firstLabel => 'Supplier name';

  @override
  String get secondLabel => 'Bill ID';

  @override
  SupplierPayment buildEntity(
    String id,
    String first,
    String second,
    double amount,
  ) {
    return SupplierPayment(
      id: id,
      projectId: projectId,
      supplierBillId: second,
      supplierName: first,
      paymentDate: DateTime.now(),
      amount: amount,
      paymentMethod: 'Bank transfer',
      reference: id,
    );
  }
}

class _ClientInvoiceDialog extends _SimpleFinanceDialog<ClientInvoice> {
  const _ClientInvoiceDialog({required super.projectId});

  @override
  String get title => 'Add client invoice';

  @override
  String get firstLabel => 'Milestone name';

  @override
  String get secondLabel => 'Invoice number';

  @override
  ClientInvoice buildEntity(
    String id,
    String first,
    String second,
    double amount,
  ) {
    final now = DateTime.now();
    return ClientInvoice(
      id: id,
      projectId: projectId,
      invoiceNumber: second,
      milestoneName: first,
      issueDate: now,
      dueDate: now.add(const Duration(days: 15)),
      amount: amount,
      status: ClientInvoiceStatus.issued,
    );
  }
}

abstract class _SimpleFinanceDialog<T> extends StatefulWidget {
  const _SimpleFinanceDialog({required this.projectId});

  final String projectId;
  String get title;
  String get firstLabel;
  String get secondLabel;
  T buildEntity(String id, String first, String second, double amount);

  @override
  State<_SimpleFinanceDialog<T>> createState() =>
      _SimpleFinanceDialogState<T>();
}

class _SimpleFinanceDialogState<T> extends State<_SimpleFinanceDialog<T>> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _second = TextEditingController();
  final _amount = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _first,
              decoration: InputDecoration(labelText: widget.firstLabel),
              validator: _required,
            ),
            TextFormField(
              controller: _second,
              decoration: InputDecoration(labelText: widget.secondLabel),
              validator: _required,
            ),
            TextFormField(
              controller: _amount,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) => double.tryParse(value?.trim() ?? '') == null
                  ? 'Enter a valid amount.'
                  : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required.' : null;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final entity = widget.buildEntity(
      '${DateTime.now().microsecondsSinceEpoch}',
      _first.text.trim(),
      _second.text.trim(),
      double.parse(_amount.text.trim()),
    );
    Navigator.pop(context, entity);
  }
}

String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/'
    '${value.month.toString().padLeft(2, '0')}/${value.year}';

String _status(Object value) => value.toString().split('.').last;
