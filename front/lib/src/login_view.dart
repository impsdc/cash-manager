import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/src/res/colors.dart';

import 'components/bezierContainer.dart';
import 'models/result.dart';
import 'services/user_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error = '';

  bool _isProcessing = false;

  _login(context) async {
    setState(() {
      _isProcessing = true;
    });
    Result response = await UserService()
        .login(emailController.text, passwordController.text) as Result;
    setState(() {
      _isProcessing = false;
    });
    if (response.status!) {
      Navigator.of(context).pushNamed('home');
    } else {
      setState(() {
        error = response.message;
      });
    }
  }

  Widget _submitButton() {
    return GestureDetector(
      onTap: () {
        _login(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey[900]!,
                  offset: const Offset(0, 2),
                  blurRadius: 5,
                  spreadRadius: 1)
            ],
            gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.primary, AppColors.primaryDark])),
        child: _isProcessing
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.connect,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
      ),
    );
  }

  Widget _title() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'Cash ',
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary),
            children: [
              TextSpan(
                text: 'Manager',
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color, fontSize: 30),
              ),
            ]),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailController,
                style: const TextStyle(
                  color: AppColors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: AppColors.gray1,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppLocalizations.of(context)!.password,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: AppColors.black,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  fillColor: AppColors.gray1,
                  filled: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _error() {
    return Container(
      child: error != null
          ? Text(
              error!,
              style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            )
          : const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .10,
              right: -MediaQuery.of(context).size.width * .4,
              child: const BezierContainer()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _title(),
                  _error(),
                  const SizedBox(height: 50),
                  _emailPasswordWidget(),
                  const SizedBox(height: 20),
                  _submitButton()
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
