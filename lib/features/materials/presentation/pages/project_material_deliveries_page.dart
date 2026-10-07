import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/material_delivery.dart';
import '../providers/material_delivery_providers.dart';
import '../providers/material_providers.dart';
import '../providers/material_requirement_providers.dart';

class ProjectMaterialDeliveriesPage extends ConsumerWidget {
  const ProjectMaterialDeliveriesPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(
      projectMaterialDeliveriesProvider(projectId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Material Deliveries')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addDelivery(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Record delivery'),
      ),
      body: deliveriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load deliveries: $error')),
        data: (deliveries) => deliveries.isEmpty
            ? const Center(child: Text('No material deliveries recorded yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: deliveries.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, index) =>
                    _DeliveryCard(delivery: deliveries[index]),
              ),
      ),
    );
  }

  Future<void> _addDelivery(BuildContext context, WidgetRef ref) async {
    final delivery = await showDialog<MaterialDelivery>(
      context: context,
      builder: (_) => _DeliveryForm(projectId: projectId),
    );
    if (delivery == null || !context.mounted) return;
    await ref.read(materialDeliveryActionsProvider).createDelivery(delivery);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material delivery recorded successfully.')),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  const _DeliveryCard({required this.delivery});

  final MaterialDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);
    final materialName = materialsAsync.when(
      loading: () => delivery.materialId,
      error: (_, _) => delivery.materialId,
      data: (materials) =>
          materials
              .where((material) => material.id == delivery.materialId)
              .map((material) => material.name)
              .firstOrNull ??
          delivery.materialId,
    );
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.local_shipping_outlined,
          color: _statusColor(context, delivery.status),
        ),
        title: Text(materialName),
        subtitle: Text(
          '${delivery.quantity} ${delivery.unit} • ${_statusLabel(delivery.status)}\n'
          '${_formatDate(delivery.deliveryDate)} • ${delivery.supplierName}\n'
          'Reference: ${delivery.referenceNumber}',
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<MaterialDeliveryStatus>(
          tooltip: 'Update delivery status',
          onSelected: (status) => _updateStatus(context, ref, status),
          itemBuilder: (_) => MaterialDeliveryStatus.values
              .map(
                (status) => PopupMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    MaterialDeliveryStatus status,
  ) async {
    await ref
        .read(materialDeliveryActionsProvider)
        .updateDelivery(
          MaterialDelivery(
            id: delivery.id,
            projectId: delivery.projectId,
            materialRequirementId: delivery.materialRequirementId,
            materialId: delivery.materialId,
            quantity: delivery.quantity,
            unit: delivery.unit,
            deliveryDate: delivery.deliveryDate,
            supplierName: delivery.supplierName,
            referenceNumber: delivery.referenceNumber,
            status: status,
            purchaseOrderId: delivery.purchaseOrderId,
            notes: delivery.notes,
          ),
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivery marked ${_statusLabel(status).toLowerCase()}.'),
      ),
    );
  }
}

class _DeliveryForm extends ConsumerStatefulWidget {
  const _DeliveryForm({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_DeliveryForm> createState() => _DeliveryFormState();
}

class _DeliveryFormState extends ConsumerState<_DeliveryForm> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _supplier = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  String? _requirementId;
  DateTime _deliveryDate = DateTime.now();
  MaterialDeliveryStatus _status = MaterialDeliveryStatus.received;

  @override
  void dispose() {
    _quantity.dispose();
    _supplier.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requirementsAsync = ref.watch(
      materialRequirementsProvider(widget.projectId),
    );
    return AlertDialog(
      title: const Text('Record material delivery'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                requirementsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Unable to load material requirements.'),
                  data: (requirements) => DropdownButtonFormField<String>(
                    initialValue: _requirementId,
                    decoration: const InputDecoration(
                      labelText: 'Material requirement',
                    ),
                    items: requirements
                        .map(
                          (requirement) => DropdownMenuItem(
                            value: requirement.id,
                            child: Text(
                              '${requirement.materialId} • '
                              '${requirement.quantity} ${requirement.unit}',
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Select a material requirement.' : null,
                    onChanged: (value) =>
                        setState(() => _requirementId = value),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _field(
                  _quantity,
                  'Delivered quantity',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.sm),
                _field(_supplier, 'Supplier'),
                const SizedBox(height: AppSpacing.sm),
                _field(_reference, 'Delivery reference'),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<MaterialDeliveryStatus>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: MaterialDeliveryStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusLabel(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Delivery date'),
                  subtitle: Text(_formatDate(_deliveryDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                _field(_notes, 'Notes', maxLines: 3, required: false),
              ],
            ),
          ),
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

  TextFormField _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter $label.';
              }
              if (label == 'Delivered quantity' &&
                  double.tryParse(value.trim()) == null) {
                return 'Enter a valid quantity.';
              }
              if (label == 'Delivered quantity' &&
                  (double.tryParse(value.trim()) ?? 0) <= 0) {
                return 'Quantity must be greater than zero.';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _deliveryDate,
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _requirementId == null) return;
    final requirements = await ref.read(
      materialRequirementsProvider(widget.projectId).future,
    );
    if (!mounted) return;
    final selected = requirements
        .where((requirement) => requirement.id == _requirementId)
        .firstOrNull;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a valid material requirement.')),
      );
      return;
    }
    Navigator.pop(
      context,
      MaterialDelivery(
        id: 'delivery-${DateTime.now().microsecondsSinceEpoch}',
        projectId: widget.projectId,
        materialRequirementId: selected.id,
        materialId: selected.materialId,
        quantity: double.parse(_quantity.text.trim()),
        unit: selected.unit,
        deliveryDate: _deliveryDate,
        supplierName: _supplier.text.trim(),
        referenceNumber: _reference.text.trim(),
        status: _status,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }
}

String _statusLabel(MaterialDeliveryStatus status) => switch (status) {
  MaterialDeliveryStatus.expected => 'Expected',
  MaterialDeliveryStatus.inTransit => 'In transit',
  MaterialDeliveryStatus.partiallyReceived => 'Partially received',
  MaterialDeliveryStatus.received => 'Received',
  MaterialDeliveryStatus.cancelled => 'Cancelled',
};

Color _statusColor(BuildContext context, MaterialDeliveryStatus status) =>
    switch (status) {
      MaterialDeliveryStatus.expected => Colors.blue,
      MaterialDeliveryStatus.inTransit => Colors.orange,
      MaterialDeliveryStatus.partiallyReceived => Colors.deepOrange,
      MaterialDeliveryStatus.received => Colors.green,
      MaterialDeliveryStatus.cancelled => Theme.of(context).colorScheme.error,
    };

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';
