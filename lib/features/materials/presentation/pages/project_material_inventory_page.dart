import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../domain/entities/material.dart' as domain;
import '../../domain/entities/material_consumption.dart';
import '../../domain/entities/material_receipt.dart';
import '../../domain/entities/material_wastage.dart';
import '../providers/material_providers.dart';
import '../providers/material_stock_providers.dart';

class ProjectMaterialInventoryPage extends ConsumerWidget {
  const ProjectMaterialInventoryPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(
      projectMaterialInventoryProvider(projectId),
    );
    final materialsAsync = ref.watch(materialsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Material Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntryMenu(context, ref, materialsAsync),
        icon: const Icon(Icons.add),
        label: const Text('Record stock movement'),
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load inventory: $error')),
        data: (summaries) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(projectMaterialInventoryProvider(projectId));
          },
          child: summaries.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 180),
                    Center(child: Text('No stock movements recorded yet.')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: summaries.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, index) {
                    final summary = summaries[index];
                    final materialName = materialsAsync.when(
                      loading: () => summary.materialId,
                      error: (_, _) => summary.materialId,
                      data: (materials) =>
                          materials
                              .where((item) => item.id == summary.materialId)
                              .map((item) => item.name)
                              .firstOrNull ??
                          summary.materialId,
                    );
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(materialName),
                        subtitle: Text(
                          'Received: ${summary.receivedQuantity} ${summary.unit}\n'
                          'Consumed: ${summary.consumedQuantity} ${summary.unit} • '
                          'Wasted: ${summary.wastedQuantity} ${summary.unit}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          '${summary.availableQuantity} ${summary.unit}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _showEntryMenu(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<domain.Material>> materialsAsync,
  ) async {
    final type = await showModalBottomSheet<_StockEntryType>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: const Text('Record material receipt'),
              subtitle: const Text('Add verified material to available stock'),
              onTap: () => Navigator.pop(context, _StockEntryType.receipt),
            ),
            ListTile(
              leading: const Icon(Icons.construction_outlined),
              title: const Text('Record material consumption'),
              subtitle: const Text('Issue material to a phase or work crew'),
              onTap: () => Navigator.pop(context, _StockEntryType.consumption),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Record material wastage'),
              subtitle: const Text('Record damaged, excess, or spoiled stock'),
              onTap: () => Navigator.pop(context, _StockEntryType.wastage),
            ),
          ],
        ),
      ),
    );
    if (type == null || !context.mounted) return;
    final loadedMaterials = materialsAsync.value;
    if (loadedMaterials == null || loadedMaterials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material catalog is not available.')),
      );
      return;
    }
    final entry = await showDialog<Object?>(
      context: context,
      builder: (_) => _StockEntryDialog(
        projectId: projectId,
        type: type,
        materials: loadedMaterials,
      ),
    );
    if (entry == null || !context.mounted) return;
    final actions = ref.read(materialStockActionsProvider);
    if (entry is MaterialReceipt) {
      await actions.createReceipt(entry);
    } else if (entry is MaterialConsumption) {
      await actions.createConsumption(entry);
    } else if (entry is MaterialWastage) {
      await actions.createWastage(entry);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Material stock movement recorded.')),
    );
  }
}

enum _StockEntryType { receipt, consumption, wastage }

class _StockEntryDialog extends StatefulWidget {
  const _StockEntryDialog({
    required this.projectId,
    required this.type,
    required this.materials,
  });

  final String projectId;
  final _StockEntryType type;
  final List<domain.Material> materials;

  @override
  State<_StockEntryDialog> createState() => _StockEntryDialogState();
}

class _StockEntryDialogState extends State<_StockEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantity = TextEditingController();
  final _person = TextEditingController();
  final _notes = TextEditingController();
  String? _materialId;
  DateTime _date = DateTime.now();
  MaterialWastageReason _reason = MaterialWastageReason.damage;

  @override
  void dispose() {
    _quantity.dispose();
    _person.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.type) {
      _StockEntryType.receipt => 'Record material receipt',
      _StockEntryType.consumption => 'Record material consumption',
      _StockEntryType.wastage => 'Record material wastage',
    };
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _materialId,
                  decoration: const InputDecoration(labelText: 'Material'),
                  items: widget.materials
                      .map(
                        (material) => DropdownMenuItem<String>(
                          value: material.id,
                          child: Text(material.name),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Select a material.' : null,
                  onChanged: (value) => setState(() => _materialId = value),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _quantity,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final quantity = double.tryParse(value?.trim() ?? '');
                    return quantity == null || quantity <= 0
                        ? 'Enter a positive quantity.'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _person,
                  decoration: InputDecoration(
                    labelText: switch (widget.type) {
                      _StockEntryType.receipt => 'Received by',
                      _StockEntryType.consumption => 'Issued to',
                      _StockEntryType.wastage => 'Reported by',
                    },
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'This field is required.'
                      : null,
                ),
                if (widget.type == _StockEntryType.wastage) ...[
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<MaterialWastageReason>(
                    initialValue: _reason,
                    decoration: const InputDecoration(labelText: 'Reason'),
                    items: MaterialWastageReason.values
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(_reasonLabel(reason)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _reason = value ?? _reason),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(_formatDate(_date)),
                  trailing: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _date,
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _materialId == null) return;
    final quantity = double.parse(_quantity.text.trim());
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    final id = '${widget.type.name}-${DateTime.now().microsecondsSinceEpoch}';
    final result = switch (widget.type) {
      _StockEntryType.receipt => MaterialReceipt(
        id: id,
        projectId: widget.projectId,
        materialId: _materialId!,
        quantity: quantity,
        unit: _unitForSelectedMaterial(),
        receivedDate: _date,
        receivedBy: _person.text.trim(),
        notes: notes,
      ),
      _StockEntryType.consumption => MaterialConsumption(
        id: id,
        projectId: widget.projectId,
        materialId: _materialId!,
        quantity: quantity,
        unit: _unitForSelectedMaterial(),
        consumedDate: _date,
        issuedTo: _person.text.trim(),
        notes: notes,
      ),
      _StockEntryType.wastage => MaterialWastage(
        id: id,
        projectId: widget.projectId,
        materialId: _materialId!,
        quantity: quantity,
        unit: _unitForSelectedMaterial(),
        wastedDate: _date,
        reason: _reason,
        reportedBy: _person.text.trim(),
        notes: notes,
      ),
    };
    Navigator.pop(context, result);
  }

  String _unitForSelectedMaterial() {
    final selected = widget.materials.firstWhere(
      (material) => material.id == _materialId,
    );
    return selected.unit.name;
  }

  static String _reasonLabel(MaterialWastageReason reason) => switch (reason) {
    MaterialWastageReason.damage => 'Damage',
    MaterialWastageReason.excess => 'Excess',
    MaterialWastageReason.spoilage => 'Spoilage',
    MaterialWastageReason.qualityIssue => 'Quality issue',
    MaterialWastageReason.other => 'Other',
  };

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
