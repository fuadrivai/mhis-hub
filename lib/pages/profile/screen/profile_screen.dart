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
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(gradient: Common.gradient),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Builder(builder: (context) {
                          final avatarUrl =
                              state.employee?.person?.avatar ?? "";
                          final hasAvatar = avatarUrl.isNotEmpty;
                          return InkWell(
                            borderRadius: BorderRadius.circular(52),
                            onTap: hasAvatar
                                ? () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ImageDialog(imageUrl: avatarUrl),
                                    );
                                  }
                                : null,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.white24,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    hasAvatar ? NetworkImage(avatarUrl) : null,
                                child: hasAvatar
                                    ? null
                                    : const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Text(
                          state.employee?.person?.fullName ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.employee?.person?.email ?? "-",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                    decoration: BoxDecoration(
                      color: AppColors.whiteshade,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
                        title(
                          color: Colors.transparent,
                          position: state.employee?.employment?.organizationName
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? state.employee?.employment?.organizationName
                              : "-",
                          title: "Division",
                        ),
                        Container(
                          width: 1,
                          height: 52,
                          color: Colors.black12,
                        ),
                        title(
                          color: Colors.transparent,
                          position: state.employee?.employment?.jobPosition
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? state.employee?.employment?.jobPosition
                              : "-",
                          title: "Position",
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: ParentMenu()
                        .menu(context, state.employee ?? EmployeeOld())
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
        color: color ?? Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              position ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
