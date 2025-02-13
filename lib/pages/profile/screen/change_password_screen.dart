import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Change Password",
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.loadingFormPassword) {
            return const LoadingWidget();
          }
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              color: AppColors.white,
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
                    CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text("Show Password"),
                      value: obsecureText,
                      onChanged: (val) {
                        setState(() {
                          obsecureText = val!;
                        });
                      },
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
