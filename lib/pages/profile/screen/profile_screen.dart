import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/pages/profile/bloc/profile_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String userEmail;
  @override
  void initState() {
    Session.get("email").then((email) {
      if (email != null || email != "") {
        setState(() {
          userEmail = email!;
          context.read<ProfileBloc>().add(OnGetUserEmail(userEmail));
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          decoration: BoxDecoration(gradient: Common.gradient),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<ProfileBloc>().add(OnGetUserEmail(userEmail)),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(gradient: Common.gradient),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const CircleAvatar(
                        backgroundColor: AppColors.success,
                        minRadius: 60.0,
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: NetworkImage(
                              'https://avatars0.githubusercontent.com/u/28812093?s=460&u=06471c90e03cfd8ce2855d217d157c93060da490&v=4'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.user?.fullName ?? "-",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        state.user?.email ?? "-",
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
                      position: "Operational",
                      title: "Division",
                    ),
                    title(
                      color: AppColors.primary,
                      position: "Staff",
                      title: "Position",
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    color: AppColors.whiteshade,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Employee Information",
                              style: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(255, 98, 95, 95),
                              ),
                            ),
                          ),
                          const Divider(thickness: 0.5),
                          customeListTile(
                            title: "Employee ID - 12345",
                            iconData: FontAwesomeIcons.idCard,
                          ),
                          customeListTile(
                            title: "Jakarta - March 7, 1989",
                            iconData: FontAwesomeIcons.calendarDays,
                          ),
                          customeListTile(
                            title: "081316007277",
                            iconData: FontAwesomeIcons.mobileScreenButton,
                          ),
                          customeListTile(
                            title: "Male",
                            iconData: FontAwesomeIcons.person,
                          ),
                          customeListTile(
                            title: "Address",
                            iconData: FontAwesomeIcons.locationDot,
                          ),
                          const Divider(thickness: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                AuthButton(
                  text: "Logout",
                  height: 50,
                  onTap: () {
                    context.read<ProfileBloc>().add(const OnLogout());
                  },
                )
              ],
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
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            title ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget customeListTile({
    required IconData? iconData,
    required String title,
    Widget? trailing,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Row(
          children: [
            Icon(
              iconData,
              color: const Color.fromARGB(255, 221, 82, 110),
            ),
            const SizedBox(width: 20),
            Text(title, style: AppColors.profileTextTheme),
            trailing ?? const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
