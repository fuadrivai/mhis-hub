import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/profile_menu.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late int userIdTalenta;
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
                                  );
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
                  const Center(
                    child: Text("Version : 1.1.1 (12345)"),
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
