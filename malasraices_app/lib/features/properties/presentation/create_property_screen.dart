import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/property_form_cubit.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bedroomsCtrl = TextEditingController(text: '0');
  final _bathroomsCtrl = TextEditingController(text: '0');
  final _areaCtrl = TextEditingController();

  String _selectedType = 'APARTMENT';

  static const _propertyTypes = {
    'APARTMENT': 'Apartamento',
    'HOUSE': 'Casa',
    'STUDIO': 'Estudio',
    'ROOM': 'Habitación',
    'COMMERCIAL': 'Comercial',
  };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    _bedroomsCtrl.dispose();
    _bathroomsCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publicar Propiedad')),
      body: BlocConsumer<PropertyFormCubit, PropertyFormState>(
        listener: (context, state) {
          if (state.status == PropertyFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Propiedad creada exitosamente')),
            );
            context.pop();
          } else if (state.status == PropertyFormStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state.status == PropertyFormStatus.submitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ej: Apartamento en el centro',
                    ),
                    maxLength: 120,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                    onChanged: (v) =>
                        context.read<PropertyFormCubit>().updateField(title: v),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      hintText: 'Describe la propiedad...',
                    ),
                    maxLines: 4,
                    maxLength: 2000,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                    onChanged: (v) => context
                        .read<PropertyFormCubit>()
                        .updateField(description: v),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio (COP) *',
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requerido';
                      if (double.tryParse(v) == null) return 'Número inválido';
                      return null;
                    },
                    onChanged: (v) => context
                        .read<PropertyFormCubit>()
                        .updateField(price: v),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      hintText: 'Ej: Calle 100 #15-20, Bogotá',
                    ),
                    maxLength: 300,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requerido' : null,
                    onChanged: (v) => context
                        .read<PropertyFormCubit>()
                        .updateField(address: v),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de propiedad *',
                    ),
                    items: _propertyTypes.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedType = v);
                        context
                            .read<PropertyFormCubit>()
                            .updateField(propertyType: v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _bedroomsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Habitaciones *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            if (int.tryParse(v) == null) return 'Inválido';
                            return null;
                          },
                          onChanged: (v) => context
                              .read<PropertyFormCubit>()
                              .updateField(bedrooms: v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bathroomsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Baños *',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Requerido';
                            if (int.tryParse(v) == null) return 'Inválido';
                            return null;
                          },
                          onChanged: (v) => context
                              .read<PropertyFormCubit>()
                              .updateField(bathrooms: v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _areaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Área (m²)',
                      hintText: 'Opcional',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => context
                        .read<PropertyFormCubit>()
                        .updateField(areaSqm: v),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<PropertyFormCubit>().submit();
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publicar Propiedad'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
