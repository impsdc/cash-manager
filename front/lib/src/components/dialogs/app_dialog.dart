import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/src/res/colors.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width*3/4,
        child: child,
      ),
    );
  }
}

class DialogTextField extends StatelessWidget {
  const DialogTextField({Key? key, this.controller, this.hint,
    this.keyboardType, this.maxLines, this.inputFormatters,
    this.label, this.suffix, this.error = false}) : super(key: key);

  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final String? suffix;
  final TextInputType? keyboardType;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: error ? Border.all(color: Colors.red, width: 1.0,)
            : Border.all(color: Colors.transparent, width: 0.0,),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          labelText: label,
          suffixText: suffix,
        ),
      ),
    );
  }
}

class DialogSubmitButton extends StatelessWidget {
  const DialogSubmitButton({Key? key, this.onSubmit, this.isProcessing = false, this.text = ""}) : super(key: key);

  final Function()? onSubmit;
  final bool isProcessing;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSubmit,
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey[900]!,
              offset: const Offset(0, 2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: isProcessing ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ) : Text(text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
