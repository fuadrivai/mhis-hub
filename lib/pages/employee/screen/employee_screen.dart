import 'dart:io';
import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/employee/bloc/employee_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    context.read<EmployeeBloc>().add(const OnInit());
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        context.read<EmployeeBloc>().add(const OnLoadMore());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: Container(
          padding: const EdgeInsets.only(left: 10),
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(Common.imageLogo),
        ),
        title: "Employee",
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<EmployeeBloc>().add(const OnInit());
        },
        child: SingleChildScrollView(
          controller: _controller,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  validator: ValidForm.emptyValue,
                  decoration: TextFormDecoration.box(
                    hintText: "Search by Employee Email...",
                  ),
                  onChanged: (str) {
                    context.read<EmployeeBloc>().add(OnSearchChanged(str));
                  },
                ),
              ),
              BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const LoadingWidget();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: Container(
                      decoration: const BoxDecoration(color: AppColors.white),
                      child: Stack(
                        alignment: AlignmentDirectional.topCenter,
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            itemCount: (state.employees ?? []).length,
                            itemBuilder: (context, index) {
                              EmployeeV3 employee =
                                  (state.employees ?? [])[index];
                              return ListTile(
                                visualDensity:
                                    const VisualDensity(vertical: -1),
                                leading: InkWell(
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => ImageDialog(
                                          imageUrl: employee.avatar ?? ""),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      employee.avatar ?? "",
                                    ),
                                  ),
                                ),
                                title: Text(
                                  employee.firstName ?? "",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(employee.email ?? ""),
                                trailing: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: employee.mobilePhone != "",
                                      child: GestureDetector(
                                        onTap: () =>
                                            phoneDial(employee.mobilePhone!),
                                        child: const FaIcon(
                                          FontAwesomeIcons.phoneFlip,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 19),
                                    GestureDetector(
                                      onTap: () => lauchEmail(employee.email!),
                                      child: const FaIcon(
                                        FontAwesomeIcons.envelope,
                                        color: AppColors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 19),
                                    Visibility(
                                      visible: (employee.mobilePhone != ""),
                                      child: GestureDetector(
                                        onTap: () =>
                                            whatsapp(employee.mobilePhone!),
                                        child: const FaIcon(
                                          FontAwesomeIcons.whatsapp,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {},
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                          ),
                          state.loadMore
                              ? const Positioned(
                                  bottom: 20,
                                  child: Center(
                                      child: CircularProgressIndicator()))
                              : const SizedBox.shrink()
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  lauchEmail(String email) async {
    final url = "mailto:$email";
    await launchUrl(Uri.parse(url));
  }

  phoneDial(String contact) async {
    final Uri url = Uri(scheme: "tel", path: contact);
    await launchUrl(url);
  }

  whatsapp(String contact) async {
    String te = contact.substring(0, 1);
    String newContact = "";
    if (te == "0") {
      newContact = replaceFirstCharacter(contact, "62");
    }
    var androidUrl = "whatsapp://send?phone=$newContact";
    var iosUrl = "https://wa.me/$newContact";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      // ignore: avoid_print
      print("wahtsapp not installed");
    }
  }

  String replaceFirstCharacter(String str, String replacement) {
    if (str.isEmpty) {
      return str;
    }
    return replacement + str.substring(1);
  }
}
