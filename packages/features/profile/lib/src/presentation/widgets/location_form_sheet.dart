import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/user_location.dart';

/// Bottom sheet con form para editar la ubicación. Devuelve `UserLocation`
/// al pop si el usuario guarda; `null` si cancela.
///
/// El back exige `destination_area`, `address.street` y `address.postal_code`.
/// `department` y `floor` son opcionales.
class LocationFormSheet extends StatefulWidget {
  const LocationFormSheet({required this.initial, super.key});

  final UserLocation? initial;

  @override
  State<LocationFormSheet> createState() => _LocationFormSheetState();
}

class _LocationFormSheetState extends State<LocationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _area = TextEditingController(text: widget.initial?.destinationArea ?? '');
  late final _street = TextEditingController(text: widget.initial?.street ?? '');
  late final _postal = TextEditingController(text: widget.initial?.postalCode ?? '');
  late final _dpt = TextEditingController(text: widget.initial?.department ?? '');
  late final _floor = TextEditingController(text: widget.initial?.floor ?? '');

  @override
  void dispose() {
    _area.dispose();
    _street.dispose();
    _postal.dispose();
    _dpt.dispose();
    _floor.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      UserLocation(
        destinationArea: _area.text.trim(),
        street: _street.text.trim(),
        postalCode: _postal.text.trim(),
        department: _dpt.text.trim().isEmpty ? null : _dpt.text.trim(),
        floor: _floor.text.trim().isEmpty ? null : _floor.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: SwColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.initial == null ? 'Configurar ubicación' : 'Editar ubicación',
                  style: SwText.display(size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  'Se usa al crear órdenes. La podés cambiar cuando quieras.',
                  style: SwText.body(size: 13, color: SwColors.text3),
                ),
                const SizedBox(height: 20),
                _Field(
                  label: 'Bahía / zona del depósito',
                  controller: _area,
                  hint: 'Ej. Bay 14',
                  required: true,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Calle y altura',
                  controller: _street,
                  hint: 'Ej. Av. Siempre Viva 742',
                  required: true,
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Código postal',
                  controller: _postal,
                  hint: 'Ej. 1414',
                  required: true,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Field(label: 'Departamento', controller: _dpt, hint: 'Opcional')),
                    const SizedBox(width: 12),
                    Expanded(child: _Field(label: 'Piso', controller: _floor, hint: 'Opcional')),
                  ],
                ),
                const SizedBox(height: 20),
                SwButton(
                  label: 'Guardar',
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancelar',
                      style: SwText.body(size: 14, color: SwColors.text3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.required = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool required;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SwText.body(size: 12, color: SwColors.text2, weight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: SwText.body(size: 14, color: SwColors.text3),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SwColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SwColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: SwColors.text, width: 1.5),
            ),
          ),
          validator: (v) {
            if (!required) return null;
            if (v == null || v.trim().isEmpty) return 'Requerido';
            return null;
          },
        ),
      ],
    );
  }
}
