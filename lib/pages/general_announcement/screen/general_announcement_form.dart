import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/branch_box.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/job_level_box.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/job_position_box.dart';
import 'package:fl_mhis_hr/pages/general_announcement/screen/organization_box.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GeneralAnnouncementForm extends StatefulWidget {
  const GeneralAnnouncementForm({super.key});

  @override
  State<GeneralAnnouncementForm> createState() =>
      _GeneralAnnouncementFormState();
}

class _GeneralAnnouncementFormState extends State<GeneralAnnouncementForm> {
  final formKey = GlobalKey<FormState>();
  bool allEmployee = true;
  @override
  void initState() {
    context.read<GeneralAnnouncementBloc>().add(const OnInitForm());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.whiteshade,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: "Announcement Form",
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          color: AppColors.white,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                DefaultFormField(
                  title: "Subject",
                  textForm: TextFormField(
                    validator: ValidForm.emptyValue,
                    decoration: TextFormDecoration.box(),
                    onChanged: (val) {
                      context
                          .read<GeneralAnnouncementBloc>()
                          .add(OnChangedSubject(val));
                    },
                  ),
                ),
                BlocBuilder<GeneralAnnouncementBloc, GeneralAnnouncementState>(
                  builder: (context, state) {
                    if (state.loadingForm) {
                      return const LoadingShimmer(height: 60);
                    }
                    return DefaultFormField(
                      title: "Category",
                      textForm: DropdownButtonFormField<AnnouncementCategory>(
                        value: state.announcement?.category,
                        items: (state.categories ?? []).map((val) {
                          return DropdownMenuItem<AnnouncementCategory>(
                            value: val,
                            child: Text(val.name ?? ""),
                          );
                        }).toList(),
                        onChanged: (val) {
                          context
                              .read<GeneralAnnouncementBloc>()
                              .add(OnChangedCategory(val!));
                        },
                        decoration: TextFormDecoration.box(),
                      ),
                    );
                  },
                ),
                DefaultFormField(
                  title: "Content",
                  textForm: TextFormField(
                    maxLines: 15,
                    minLines: 4,
                    decoration: TextFormDecoration.box(),
                    onChanged: (val) {
                      context
                          .read<GeneralAnnouncementBloc>()
                          .add(OnChangedContent(val));
                    },
                  ),
                ),
                DefaultFormField(
                  title: "Link",
                  textForm: TextFormField(
                    validator: ValidForm.emptyValue,
                    decoration: TextFormDecoration.box(
                      hintText: "https://www.example.com/",
                    ),
                    onChanged: (val) {
                      context
                          .read<GeneralAnnouncementBloc>()
                          .add(OnChangedLink(val));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Post to all employees",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      BlocBuilder<GeneralAnnouncementBloc,
                          GeneralAnnouncementState>(
                        builder: (context, state) {
                          return CupertinoSwitch(
                            value: allEmployee,
                            onChanged: (val) {
                              context
                                  .read<GeneralAnnouncementBloc>()
                                  .add(OnChangedPostAllEmployee(val));
                              allEmployee = val;
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                BlocBuilder<GeneralAnnouncementBloc, GeneralAnnouncementState>(
                  builder: (context, state) {
                    return Visibility(
                      visible: !allEmployee,
                      child: Column(
                        children: [
                          BranchBox(
                            branches: state.branches ?? [],
                            announcement: state.announcement ?? Announcement(),
                          ),
                          OrganizationBox(
                            organizations: state.organizations ?? [],
                            announcement: state.announcement ?? Announcement(),
                          ),
                          JobLevelBox(
                            levels: state.levels ?? [],
                            announcement: state.announcement ?? Announcement(),
                          ),
                          JobPositionBox(
                            positions: state.positions ?? [],
                            announcement: state.announcement ?? Announcement(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    bool isValid = formKey.currentState!.validate();
                    if (isValid) {
                      context
                          .read<GeneralAnnouncementBloc>()
                          .add(const OnSubmit());
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.08,
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: BlocBuilder<GeneralAnnouncementBloc,
                          GeneralAnnouncementState>(
                        builder: (context, state) {
                          if (state.loadingButton) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                              ),
                            );
                          }
                          return const Text(
                            "Submit",
                            textAlign: TextAlign.center,
                            style: KTextStyle.authButtonTextStyle,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
