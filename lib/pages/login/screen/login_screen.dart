import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isVisible = true;
  IconData iconData = Icons.visibility;

  String get email => _emailController.text.trim();
  String get password => _passwordController.text.trim();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        String? token = await Session.get("token");
        if (token != "" || token != null) {
          // ignore: use_build_context_synchronously
          context.go("/splash");
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            color: AppColors.primary,
          ),
        ),
        body: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.isError) {
              Common.modalInfo(
                context,
                title: "Error",
                message: state.errorMessage,
                mode: MODE.error,
                showAction: state.showAction,
              );
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: AppColors.primary,
                ),
                const CustomHeader(text: 'Log In.'),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.08,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: AppColors.whiteshade,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        Image.asset(
                          'assets/images/logo-hub.png',
                          scale: 1,
                          height: 150,
                        ),
                        // Image.asset('assets/images/logo-hub.png'),
                        const SizedBox(
                          height: 24,
                        ),
                        CustomFormField(
                          headingText: "Email",
                          hintText: "Email",
                          obsecureText: false,
                          suffixIcon: const SizedBox(),
                          controller: _emailController,
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          headingText: "Password",
                          maxLines: 1,
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.text,
                          hintText: "At least 8 Character",
                          obsecureText: isVisible,
                          suffixIcon: IconButton(
                            icon: Icon(iconData),
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                                iconData = Icons.visibility_off;
                              });
                            },
                          ),
                          controller: _passwordController,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        BlocBuilder<LoginBloc, LoginState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return AuthButton(
                              onTap: () {
                                context.read<LoginBloc>().add(OnLogin({
                                      "email": _emailController.text,
                                      "password": _passwordController.text
                                    }));
                              },
                              text: 'Sign In',
                            );
                          },
                        ),
                      ],
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
