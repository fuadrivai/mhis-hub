import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/widget/themed_page.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  bool obsecureText = false;
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ThemedPage(
        title: 'Change Password',
        subtitle: 'Keep your account secure',
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.loadingFormPassword) {
              return const LoadingWidget();
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.danger.withValues(alpha: 0.1),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      DefaultFormField(
                        title: "Current Password",
                        textForm: TextFormField(
                          obscureText: !obsecureText,
                          controller: currentPasswordController,
                          validator: ValidForm.emptyValue,
                          decoration: TextFormDecoration.box(),
                        ),
                      ),
                      DefaultFormField(
                        title: "New Password",
                        textForm: TextFormField(
                          obscureText: !obsecureText,
                          controller: newPasswordController,
                          validator: (value) => ValidForm.matchValue(
                              value,
                              confirmPasswordController.text,
                              "Password not match"),
                          decoration: TextFormDecoration.box(),
                        ),
                      ),
                      DefaultFormField(
                        title: "Confirm New Password",
                        textForm: TextFormField(
                          obscureText: !obsecureText,
                          controller: confirmPasswordController,
                          validator: (value) => ValidForm.matchValue(value,
                              newPasswordController.text, "Password not match"),
                          decoration: TextFormDecoration.box(),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.danger,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text("Show Password"),
                          value: obsecureText,
                          onChanged: (val) {
                            setState(() {
                              obsecureText = val!;
                            });
                          },
                        ),
                      ),
                      AuthButton(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            Map<String, dynamic> data = {
                              "oldPassword": currentPasswordController.text,
                              "newPassword": newPasswordController.text
                            };
                            context
                                .read<ProfileBloc>()
                                .add(OnChangePassword(data));
                          }
                        },
                        text: "Submit",
                        height: 52,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
