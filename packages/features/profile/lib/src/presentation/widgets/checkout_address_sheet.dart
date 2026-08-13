import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/user_address.dart';

/// Resultado del sheet: el destino de la orden + opcionalmente flag para
/// persistir el address al perfil.
class CheckoutAddressResult {
  const CheckoutAddressResult({
    required this.destinationArea,
    required this.address,
    required this.saveToProfile,
  });

  final String destinationArea;
  final UserAddress address;

  /// Si true, el caller debe llamar `cubit.updateProfile(address: ...)` para
  /// persistir el address al perfil via PATCH /users/me.
  final bool saveToProfile;
}

/// Sheet que se abre en el cart checkout para juntar:
///   - `destination_area` (zona del depósito — siempre requerido por orden)
///   - `address` (calle, CP, dpto, piso — pre-populado con el address
///     del usuario si lo tiene)
///   - checkbox "Guardar en mi perfil" para que el address quede
///     persistido para próximas órdenes.
class CheckoutAddressSheet extends StatefulWidget {
  const CheckoutAddressSheet({
    required this.initialAddress,
    super.key,
  });

  /// Address actual del usuario (si tiene). Pre-popula los campos del form.
  final UserAddress? initialAddress;

  @override
  State<CheckoutAddressSheet> createState() => _CheckoutAddressSheetState();
}

class _CheckoutAddressSheetState extends State<CheckoutAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _area;
  late final TextEditingController _street;
  late final TextEditingController _postal;
  late final TextEditingController _dpt;
  late final TextEditingController _floor;
  late bool _saveToProfile;

  @override
  void initState() {
    super.initState();
    final a = widget.initialAddress;
    _area = TextEditingController(text: 'Bay 14');
    _street = TextEditingController(text: a?.street ?? '');
    _postal = TextEditingController(text: a?.postalCode ?? '');
    _dpt = TextEditingController(text: a?.department ?? '');
    _floor = TextEditingController(text: a?.floor ?? '');
    // Si NO había address guardada, por default sugerimos guardarla.
    // Si había, no la guardamos (el usuario ya la editó desde perfil si quiso).
    _saveToProfile = a == null;
  }

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
      CheckoutAddressResult(
        destinationArea: _area.text.trim(),
        address: UserAddress(
          street: _street.text.trim(),
          postalCode: _postal.text.trim(),
          department: _dpt.text.trim().isEmpty ? null : _dpt.text.trim(),
          floor: _floor.text.trim().isEmpty ? null : _floor.text.trim(),
        ),
        saveToProfile: _saveToProfile,
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
                  'Confirmar entrega',
                  style: SwText.display(size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.initialAddress != null
                      ? 'Tu dirección guardada se autocompleta. Podés ajustarla solo para esta orden.'
                      : 'Completá los datos de entrega para crear la orden.',
                  style: SwText.body(size: 13, color: SwColors.text3),
                ),
                const SizedBox(height: 18),
                _Field(
                  fieldKey: E2eKeys.checkoutAddressStreet,
                  label: 'Calle y altura',
                  controller: _street,
                  hint: 'Ej. Av. Corrientes 1234',
                  required: true,
                ),
                const SizedBox(height: 12),
                _Field(
                  fieldKey: E2eKeys.checkoutAddressPostalCode,
                  label: 'Código postal',
                  controller: _postal,
                  hint: 'Ej. C1043',
                  required: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        label: 'Departamento',
                        controller: _dpt,
                        hint: 'Opcional',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        label: 'Piso',
                        controller: _floor,
                        hint: 'Opcional',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () =>
                      setState(() => _saveToProfile = !_saveToProfile),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _saveToProfile,
                          onChanged: (v) =>
                              setState(() => _saveToProfile = v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        Expanded(
                          child: Text(
                            'Guardar esta dirección en mi perfil',
                            style: SwText.body(size: 13, color: SwColors.text2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwButton(
                  key: E2eKeys.checkoutAddressSubmit,
                  label: 'Confirmar y crear orden',
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
    this.fieldKey,
  });

  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SwText.body(
            size: 12,
            color: SwColors.text2,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          key: fieldKey,
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: SwText.body(size: 14, color: SwColors.text3),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
