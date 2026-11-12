import 'package:another_flushbar/flushbar.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/profile_menu.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/pages/login/screen/auth_layout.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your account and settings',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            tooltip: 'Profile options',
            icon: const FaIcon(FontAwesomeIcons.gear, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => context.goNamed("change-password"),
                child: const Text("Change Password"),
              ),
              PopupMenuItem(
                onTap: () => context.read<ProfileBloc>().add(const OnLogout()),
                child: const Text("Logout"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStatus extends StatelessWidget {
  const _ProfileStatus({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ProfileHeader(),
          if (isLoading) ...[
            const LoadingShimmer(height: 200),
            const LoadingShimmer(height: 90),
            const LoadingShimmer(height: 160),
          ] else
            _ProfileError(message: message, onRetry: onRetry),
        ],
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message ?? 'Unable to load profile. Please try again.'),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

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
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.paddingOf(context).top + 220,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: Common.homeHeaderGradient),
            ),
          ),
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<ProfileBloc>().add(OnGetUserById()),
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  isBiometric = state.isBiometric ?? false;
                  if (state.isLoading ||
                      (state.isError && state.employee == null)) {
                    return _ProfileStatus(
                      isLoading: state.isLoading,
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<ProfileBloc>().add(OnGetUserById()),
                    );
                  }
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: <Widget>[
                        const _ProfileHeader(),
                        if (state.isError)
                          _ProfileError(
                            message: state.errorMessage,
                            onRetry: () => context.read<ProfileBloc>().add(
                                  OnGetUserById(),
                                ),
                          ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
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
                                        backgroundColor: AppColors.danger
                                            .withValues(alpha: 0.12),
                                        child: CircleAvatar(
                                          radius: 48,
                                          backgroundColor: Colors.white,
                                          backgroundImage: avatarProvider,
                                          child: avatarProvider != null
                                              ? null
                                              : const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: AppColors.danger,
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 6,
                                        bottom: 3,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: AppColors.danger,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 17,
                                            color: AppColors.whiteshade,
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
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.employee?.personal?.email ?? "-",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.1)),
                          ),
                          child: Row(
                            children: <Widget>[
                              title(
                                color: Colors.transparent,
                                position: state.employee?.employment
                                            ?.organization?.name
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? state.employee?.employment?.organization
                                        ?.name
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
                                position: state.employee?.employment
                                            ?.jobPosition?.name
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? state
                                        .employee?.employment?.jobPosition?.name
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
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                      color: AppColors.danger
                                          .withValues(alpha: 0.1)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    TextTitle(
                                      title: menu.parent ?? "",
                                      textStyle: const TextStyle(
                                        color: AppColors.dark,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    Column(
                                      children: (menu.child ?? []).map((child) {
                                        return ListTile(
                                            leading: FaIcon(
                                              child.iconData,
                                              size: 20,
                                              color: AppColors.danger,
                                            ),
                                            title: Text(child.name ?? ""),
                                            onTap: child.onTap,
                                            trailing: child.defaultTrailing ==
                                                    true
                                                ? const Icon(
                                                    Icons.chevron_right,
                                                    color: Colors.black45,
                                                  )
                                                : (state.canAuthenticateWithBiometrics ??
                                                        false)
                                                    ? Switch(
                                                        value: isBiometric,
                                                        activeTrackColor:
                                                            AppColors.danger
                                                                .withValues(
                                                                    alpha: 0.3),
                                                        activeThumbColor:
                                                            AppColors.danger,
                                                        onChanged:
                                                            (value) async {
                                                          if (value) {
                                                            await _showPasswordDialog();
                                                          } else {
                                                            context
                                                                .read<
                                                                    ProfileBloc>()
                                                                .add(
                                                                    OnResetAuthenticationBiometrics(
                                                                        value));
                                                          }
                                                        },
                                                      )
                                                    : const Icon(
                                                        Icons.chevron_right,
                                                        color: Colors.black45,
                                                      ));
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: AuthButton(
                            text: "Logout",
                            height: 50,
                            onTap: () {
                              context.read<ProfileBloc>().add(const OnLogout());
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                              "Version : ${state.packageInfo?.version ?? ""}"),
                        ),
                        const SizedBox(height: 25)
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
          constraints: const BoxConstraints(maxWidth: 400),
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
                    const Expanded(
                      child: Text(
                        "Profile Picture",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
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
    bool isSubmitting = false;
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(builder: (dialogContext, setDialogState) {
          Future<void> submit() async {
            if (isSubmitting || !formKey.currentState!.validate()) return;
            setDialogState(() => isSubmitting = true);
            try {
              final password = await Session.get("password");
              if (!dialogContext.mounted || !mounted) return;
              if (password != _passwordController.text) {
                Common.flushBar(context,
                    title: "error", message: "Wrong Password");
                return;
              }
              await _authenticateWithBiometrics();
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
            } catch (error) {
              if (mounted) {
                Common.flushBar(context,
                    title: "error", message: "Unable to verify password");
              }
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => isSubmitting = false);
              }
            }
          }

          return PopScope(
            canPop: !isSubmitting,
            child: Dialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.fingerprint,
                                  color: AppColors.danger, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Enable Biometric',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Enter your password to enable biometric login.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          obscureText: !obscureText,
                          controller: _passwordController,
                          enabled: !isSubmitting,
                          validator: ValidForm.emptyValue,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => submit(),
                          decoration: authFieldDecoration('Password').copyWith(
                            suffixIcon: IconButton(
                              tooltip: obscureText
                                  ? 'Hide password'
                                  : 'Show password',
                              onPressed: isSubmitting
                                  ? null
                                  : () {
                                      setDialogState(
                                          () => obscureText = !obscureText);
                                    },
                              icon: Icon(
                                obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => Navigator.of(dialogContext).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  minimumSize: const Size(0, 48),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AuthAction(
                                label: 'Save',
                                isLoading: isSubmitting,
                                onPressed: submit,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
    if (mounted) {
      _passwordController.clear();
      obscureText = false;
    }
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
        if (!mounted) return;
        setState(() => isBiometric = true);
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
