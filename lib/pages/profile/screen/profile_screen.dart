import 'package:another_flushbar/flushbar.dart';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/profile_menu.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int userIdTalenta;
  bool isBiometric = false;
  bool obscureText = false;
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    Session.get("userIdTalenta").then((id) {
      if (id != null || id != "") {
        setState(() {
          userIdTalenta = int.parse(id!);
          context.read<ProfileBloc>().add(OnGetUserById(userIdTalenta));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(35),
        child: Container(
          padding: const EdgeInsets.only(top: 30, right: 10),
          decoration: BoxDecoration(gradient: Common.gradient),
          child: Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton(
              icon: const FaIcon(
                FontAwesomeIcons.gear,
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    child: const Text("Change Password"),
                    onTap: () => context.goNamed("change-password"),
                  ),
                  PopupMenuItem(
                    child: const Text("Logout"),
                    onTap: () {
                      context.read<ProfileBloc>().add(const OnLogout());
                    },
                  )
                ];
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<ProfileBloc>().add(OnGetUserById(userIdTalenta)),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            isBiometric = state.isBiometric ?? false;
            if (state.isLoading) {
              return const LoadingWidget();
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(gradient: Common.gradient),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () async {
                            await showDialog(
                              context: context,
                              builder: (_) => ImageDialog(
                                imageUrl: state.employee?.person?.avatar ?? "",
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: AppColors.danger,
                            minRadius: 60.0,
                            child: CircleAvatar(
                              radius: 59.5,
                              backgroundImage: NetworkImage(
                                state.employee?.person?.avatar ?? "",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          state.employee?.person?.fullName ?? "-",
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          state.employee?.person?.email ?? "-",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      title(
                        color: AppColors.primary2,
                        position:
                            state.employee?.employment?.organizationName ?? "-",
                        title: "Division",
                      ),
                      title(
                        color: AppColors.primary,
                        position:
                            state.employee?.employment?.jobPosition ?? "-",
                        title: "Position",
                      ),
                    ],
                  ),
                  Column(
                    children: ParentMenu()
                        .menu(context, state.employee ?? Employee())
                        .map((menu) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          color: AppColors.whiteshade,
                          child: Column(
                            children: [
                              TextTitle(title: menu.parent ?? ""),
                              Column(
                                children: (menu.child ?? []).map((child) {
                                  return TileList(
                                      title: child.name ?? "",
                                      iconData: child.iconData,
                                      onTap: child.onTap,
                                      trailling: child.defaultTrailing == true
                                          ? null
                                          : (state.canAuthenticateWithBiometrics ??
                                                  false)
                                              ? Switch(
                                                  value: isBiometric,
                                                  activeTrackColor:
                                                      const Color.fromARGB(
                                                          255, 209, 237, 149),
                                                  activeThumbColor:
                                                      AppColors.primary,
                                                  inactiveThumbColor:
                                                      AppColors.primary,
                                                  onChanged: (value) async {
                                                    if (value) {
                                                      await _showPasswordDialog();
                                                    } else {
                                                      context
                                                          .read<ProfileBloc>()
                                                          .add(
                                                              OnResetAuthenticationBiometrics(
                                                                  value));
                                                    }
                                                  },
                                                )
                                              : null);
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  AuthButton(
                    text: "Logout",
                    height: 50,
                    onTap: () {
                      context.read<ProfileBloc>().add(const OnLogout());
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child:
                        Text("Version : ${state.packageInfo?.version ?? ""}"),
                  ),
                  const SizedBox(height: 25)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showPasswordDialog() async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false, // supaya ga bisa dismiss tanpa input
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: AppColors.white,
            child: SingleChildScrollView(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                color: AppColors.white,
                child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: DefaultFormField(
                            title: "Enter Your Password",
                            textForm: TextFormField(
                              obscureText: !obscureText,
                              controller: _passwordController,
                              validator: ValidForm.emptyValue,
                              decoration: TextFormDecoration.box(),
                            ),
                          ),
                        ),
                        CheckboxListTile(
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text("Show Password"),
                          value: obscureText,
                          onChanged: (val) {
                            setState(() {
                              obscureText = val!;
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: AuthButton(
                            onTap: () async {
                              String? password = await Session.get("password");
                              if (formKey.currentState!.validate()) {
                                if (password == _passwordController.text) {
                                  await _authenticateWithBiometrics();
                                  if (!mounted) return;
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(context);
                                } else {
                                  if (!mounted) return;
                                  // ignore: use_build_context_synchronously
                                  Common.flushBar(context,
                                      title: "error",
                                      message: "Wrong Password");
                                }
                              }
                            },
                            text: "Save",
                            color: AppColors.primary,
                            height: 40,
                          ),
                        )
                      ],
                    )),
              ),
            ),
          );
        });
      },
    );
    _passwordController.clear();
    obscureText = false;
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to enable biometric login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        setState(() => isBiometric = true);
        if (!mounted) return;
        context
            .read<ProfileBloc>()
            .add(OnResetAuthenticationBiometrics(isBiometric));
        Common.flushBar(
          context,
          title: "Success",
          message: "Biometric enabled successfully ✅",
          position: FlushbarPosition.BOTTOM,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Biometric authentication failed ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
  }

  Widget title({
    String? title,
    String? position,
    Color? color,
  }) {
    return Expanded(
      child: Container(
        color: color ?? AppColors.primary,
        child: ListTile(
          title: Text(
            position ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            title ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
