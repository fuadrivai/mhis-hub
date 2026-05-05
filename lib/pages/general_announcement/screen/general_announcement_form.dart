import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class GeneralAnnouncementForm extends StatefulWidget {
  const GeneralAnnouncementForm({super.key});

  @override
  State<GeneralAnnouncementForm> createState() =>
      _GeneralAnnouncementFormState();
}

class _GeneralAnnouncementFormState extends State<GeneralAnnouncementForm> {
  final formKey = GlobalKey<FormState>();
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
                            value: state.announcement?.allEmployees ?? false,
                            onChanged: (val) {
                              context
                                  .read<GeneralAnnouncementBloc>()
                                  .add(OnChangedPostAllEmployee(val));
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
                      visible: !(state.announcement?.allEmployees ?? false),
                      child: Column(
                        children: [
                          DefaultFormField(
                            title: "Branch",
                            textForm: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      "Filter (${(state.announcement?.branches ?? []).length.toString()})"),
                              onTap: () => onTapBranch(
                                title: "Select Branch",
                                data1: state.branches ?? [],
                                data2: state.announcement?.branches ?? [],
                                onChanged: (p0, p1) {
                                  context
                                      .read<GeneralAnnouncementBloc>()
                                      .add(OnChangeBranches(p0 as Branch, p1!));
                                  setState(() {});
                                },
                              ),
                              readOnly: true,
                              decoration: TextFormDecoration.box(
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                          DefaultFormField(
                            title: "Organization",
                            textForm: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      "Filter (${(state.announcement?.organizations ?? []).length.toString()})"),
                              onTap: () => onTapBranch(
                                title: "Select Organizations",
                                data1: state.organizations ?? [],
                                data2: state.announcement?.organizations ?? [],
                                onChanged: (p0, p1) {
                                  context
                                      .read<GeneralAnnouncementBloc>()
                                      .add(OnChangeOrganization(p0, p1!));
                                },
                              ),
                              readOnly: true,
                              decoration: TextFormDecoration.box(
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                          DefaultFormField(
                            title: "Job Levels",
                            textForm: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      "Filter (${(state.announcement?.levels ?? []).length.toString()})"),
                              onTap: () => onTapBranch(
                                title: "Select Levels",
                                data1: state.levels ?? [],
                                data2: state.announcement?.levels ?? [],
                                onChanged: (p0, p1) {
                                  context
                                      .read<GeneralAnnouncementBloc>()
                                      .add(OnChangeLevel(p0, p1!));
                                },
                              ),
                              readOnly: true,
                              decoration: TextFormDecoration.box(
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                            ),
                          ),
                          DefaultFormField(
                            title: "Job Positions",
                            textForm: TextFormField(
                              controller: TextEditingController(
                                  text:
                                      "Filter (${(state.announcement?.positions ?? []).length.toString()})"),
                              onTap: () => onTapBranch(
                                title: "Select Positions",
                                data1: state.positions ?? [],
                                data2: state.announcement?.positions ?? [],
                                onChanged: (p0, p1) {
                                  context
                                      .read<GeneralAnnouncementBloc>()
                                      .add(OnChangePosition(p0, p1!));
                                },
                              ),
                              readOnly: true,
                              decoration: TextFormDecoration.box(
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                            ),
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
                      // Once submission is successful, show a success dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Submission Successful'),
                            content: const Text(
                                'The announcement has been successfully sent.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Close the dialog and go back to the previous page
                                  Navigator.of(context).pop(); // Close dialog
                                  context.pop(); // Go back to the previous page
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
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

  onTapBranch({
    required String title,
    required List data1,
    required List data2,
    required Function(dynamic, bool?)? onChanged,
  }) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      title,
                      style: const TextStyle(),
                    ),
                  ),
                  const Divider(),
                  ListView.builder(
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data1.length,
                    itemBuilder: (context, index) {
                      dynamic val = data1[index];
                      return CheckboxListTile(
                        title: Text(val.name ?? "--"),
                        value: data2.contains(val),
                        onChanged: (value) {
                          setState(() {
                            onChanged!(val, value!);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((val) {
      setState(() {});
    });
  }
}
