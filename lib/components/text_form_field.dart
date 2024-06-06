import 'package:flutter/material.dart';
import 'package:muni_san_roman/utils/utils.dart';

class MyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String label;
  final bool obscureText;
  final Function(String)? customValidation;
  final bool? isPasswordField;
  final void Function()? onPressSuffixPasswordField;

  const MyTextFormField(
      {super.key,
      required this.controller,
      required this.label,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.customValidation,
      this.isPasswordField = false,
      this.onPressSuffixPasswordField});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }
        if (customValidation != null) {
          return customValidation!(value);
        }
        return null;
      },
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        suffixIcon: isPasswordField == true
            ? obscureText
                ? IconButton(
                    icon: const Icon(Icons.visibility_rounded),
                    onPressed: onPressSuffixPasswordField,
                  )
                : IconButton(
                    onPressed: onPressSuffixPasswordField,
                    icon: const Icon(Icons.visibility_off),
                  )
            : null,
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(backgroundColor: Colors.white),
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(CustomStyles.borderRadius)),
      ),
      obscureText: obscureText,
    );
  }
}
