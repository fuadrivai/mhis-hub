import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/login/bloc/login_bloc.dart';
import 'package:fl_mhis_hr/pages/login/screen/auth_layout.dart';
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
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    context.read<LoginBloc>().add(OnLogin({
          'email': _emailController.text,
          'password': _passwordController.text,
        }));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (!state.isSuccess) return;
        final token = await Session.get('token');
        if (!context.mounted) return;
        if (token != null && token.isNotEmpty) context.go('/splash');
      },
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.isInactive) {
            context.go('/account-inactive');
          } else if (state.isError) {
            Common.modalInfo(
              context,
              title: 'Error',
              message: state.errorMessage,
              mode: MODE.error,
              showAction: state.showAction,
            );
          }
        },
        child: AuthLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthTitle('LOGIN'),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                decoration: authFieldDecoration('Email'),
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) => TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) {
                    if (!state.isLoading) _signIn();
                  },
                  decoration: authFieldDecoration('Password').copyWith(
                    suffixIcon: IconButton(
                      tooltip:
                          _obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() {
                        _obscurePassword = !_obscurePassword;
                      }),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.blackshade,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              BlocBuilder<LoginBloc, LoginState>(
                builder: (context, state) => AuthAction(
                  label: 'Sign In',
                  isLoading: state.isLoading,
                  onPressed: _signIn,
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppColors.danger),
                  child: const Text('Forgot Password?'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
