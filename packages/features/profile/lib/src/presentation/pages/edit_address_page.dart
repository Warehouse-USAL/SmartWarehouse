import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:profile/src/domain/entities/user_address.dart';
import 'package:profile/src/presentation/bloc/profile_cubit.dart';

/// Página dedicada a configurar / editar la dirección de entrega.
///
/// Por ahora solo se edita la address — no name ni otros campos. Cuando el
/// scope de edit profile crezca (email, foto, etc) se renombra a EditProfilePage.
///
/// Al guardar invoca `cubit.updateProfile(address: ...)` que pega al
/// `PATCH /users/me`.
class EditAddressPage extends StatefulWidget {
  const EditAddressPage({required this.cubit, super.key});

  final ProfileCubit cubit;

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _street;
  late final TextEditingController _postal;
  late final TextEditingController _dpt;
  late final TextEditingController _floor;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final state = widget.cubit.state;
    final addr = state is ProfileReady ? state.user.address : null;
    _street = TextEditingController(text: addr?.street ?? '');
    _postal = TextEditingController(text: addr?.postalCode ?? '');
    _dpt = TextEditingController(text: addr?.department ?? '');
    _floor = TextEditingController(text: addr?.floor ?? '');
  }

  @override
  void dispose() {
    _street.dispose();
    _postal.dispose();
    _dpt.dispose();
    _floor.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final newAddress = UserAddress(
      street: _street.text.trim(),
      postalCode: _postal.text.trim(),
      department: _dpt.text.trim().isEmpty ? null : _dpt.text.trim(),
      floor: _floor.text.trim().isEmpty ? null : _floor.text.trim(),
    );
    final ok = await widget.cubit.updateProfile(address: newAddress);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Injector.i.resolve<NavigationHelper>().pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Reintentá.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAddress = (widget.cubit.state is ProfileReady) &&
        (widget.cubit.state as ProfileReady).user.address != null;
    return Scaffold(
      backgroundColor: SwColors.surface,
      appBar: AppBar(
        backgroundColor: SwColors.white,
        elevation: 0,
        title: Text(
          hasAddress ? 'Editar dirección' : 'Agregar dirección',
          style: SwText.display(size: 22),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SwColors.text),
          onPressed: () =>
              Injector.i.resolve<NavigationHelper>().pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIRECCIÓN DE ENTREGA',
                        style: SwText.mono(size: 11, color: SwColors.text3),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Se autocompleta al crear órdenes. Podés cambiarla cuando quieras.',
                        style: SwText.body(size: 12, color: SwColors.text3),
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        label: 'Calle y altura',
                        controller: _street,
                        hint: 'Ej. Av. Corrientes 1234',
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      _Field(
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SwButton(
                  label: _saving ? 'Guardando…' : 'Guardar dirección',
                  onPressed: _saving ? () {} : _submit,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Injector.i.resolve<NavigationHelper>().pop(context),
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
  });

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
