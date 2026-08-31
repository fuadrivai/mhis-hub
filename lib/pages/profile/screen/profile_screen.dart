import 'package:another_flushbar/flushbar.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/profile_menu.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isBiometric = false;
  bool obscureText = false;
  Uint8List? _avatarPreviewBytes;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    context.read<ProfileBloc>().add(OnGetUserById());
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
        onRefresh: () async => context.read<ProfileBloc>().add(OnGetUserById()),
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
                              state.employee?.personal?.avatar ?? "";
                          final hasAvatar = avatarUrl.isNotEmpty;
                          final ImageProvider? avatarProvider =
                              _avatarPreviewBytes != null
                                  ? MemoryImage(_avatarPreviewBytes!)
                                  : (hasAvatar
                                      ? NetworkImage(
                                          "${Api.url}/storage/$avatarUrl")
                                      : null);
                          return InkWell(
                            borderRadius: BorderRadius.circular(52),
                            onTap: () async {
                              await _showAvatarPreviewDialog(
                                avatarUrl: avatarUrl,
                              );
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: Colors.white24,
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.white,
                                    backgroundImage: avatarProvider,
                                    child: avatarProvider != null
                                        ? null
                                        : const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: AppColors.primary,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: 6,
                                  bottom: 3,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        Text(
                          state.employee?.personal?.fullname ?? "-",
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
                          state.employee?.personal?.email ?? "-",
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
                          position: state
                                      .employee?.employment?.organization?.name
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? state.employee?.employment?.organization?.name
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
                          position: state
                                      .employee?.employment?.jobPosition?.name
                                      ?.trim()
                                      .isNotEmpty ==
                                  true
                              ? state.employee?.employment?.jobPosition?.name
                              : "-",
                          title: "Position",
                        ),
                      ],
                    ),
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

  Future<void> _showAvatarPreviewDialog({required String avatarUrl}) async {
    if (!mounted) return;

    final hasNetworkAvatar = avatarUrl.trim().isNotEmpty;
    final ImageProvider? avatarProvider = _avatarPreviewBytes != null
        ? MemoryImage(_avatarPreviewBytes!)
        : (hasNetworkAvatar
            ? NetworkImage("${Api.url}/storage/$avatarUrl")
            : null);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Profile Picture",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(dialogContext),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.whiteshade,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: avatarProvider != null
                        ? Image(
                            image: avatarProvider,
                            fit: BoxFit.contain,
                            height: 260,
                          )
                        : const Icon(
                            Icons.person,
                            size: 90,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AuthButton(
                    text: "Edit Picture",
                    height: 42,
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      await _showImageSourceBottomSheet();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImageSourceBottomSheet() async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Choose Picture Source",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Picture"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAvatarImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Get From Gallery"),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickAvatarImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAvatarImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

      final employeeId = context.read<ProfileBloc>().state.employee?.id;
      if (employeeId == null) {
        Common.flushBar(
          context,
          title: "error",
          message: "Employee ID not found",
        );
        return;
      }

      final body = {
        "employee_id": employeeId,
        "image": base64Encode(bytes),
      };
      context.read<ProfileBloc>().add(OnRegisterFace(body));
    } catch (e) {
      if (!mounted) return;
      Common.flushBar(
        context,
        title: "error",
        message: "Failed to load picture",
      );
    }
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
