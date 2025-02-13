import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class JobLevelBox extends StatefulWidget {
  final Announcement announcement;
  final List<JobLevel> levels;
  const JobLevelBox(
      {super.key, required this.announcement, required this.levels});

  @override
  State<JobLevelBox> createState() => _JobLevelBoxState();
}

class _JobLevelBoxState extends State<JobLevelBox> {
  @override
  Widget build(BuildContext context) {
    return DefaultFormField(
      title: "Job Levels",
      textForm: TextFormField(
        controller: TextEditingController(
            text:
                "Filter (${(widget.announcement.levels ?? []).length.toString()})"),
        onTap: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Select Levels",
                            style: TextStyle(),
                          ),
                        ),
                        const Divider(),
                        ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.levels.length,
                          itemBuilder: (context, index) {
                            JobLevel val = widget.levels[index];
                            return CheckboxListTile(
                              title: Text(val.name ?? "--"),
                              value: (widget.announcement.levels ?? [])
                                  .contains(val),
                              onChanged: (value) {
                                context
                                    .read<GeneralAnnouncementBloc>()
                                    .add(OnChangeLevel(val, value!));
                                setState(() {});
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
          ).then((val) => setState(() {}));
        },
        readOnly: true,
        decoration: TextFormDecoration.box(
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
      ),
    );
  }
}
