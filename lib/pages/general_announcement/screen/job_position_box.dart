import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/job_postion.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class JobPositionBox extends StatefulWidget {
  final Announcement announcement;
  final List<JobPosition> positions;
  const JobPositionBox(
      {super.key, required this.announcement, required this.positions});

  @override
  State<JobPositionBox> createState() => _JobPositionBoxState();
}

class _JobPositionBoxState extends State<JobPositionBox> {
  @override
  Widget build(BuildContext context) {
    return DefaultFormField(
      title: "Job Positions",
      textForm: TextFormField(
        controller: TextEditingController(
            text:
                "Filter (${(widget.announcement.positions ?? []).length.toString()})"),
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
                            "Select Positions",
                            style: TextStyle(),
                          ),
                        ),
                        const Divider(),
                        ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.positions.length,
                          itemBuilder: (context, index) {
                            JobPosition val = widget.positions[index];
                            return CheckboxListTile(
                              title: Text(val.name ?? "--"),
                              value: (widget.announcement.positions ?? [])
                                  .contains(val),
                              onChanged: (value) {
                                context
                                    .read<GeneralAnnouncementBloc>()
                                    .add(OnChangePosition(val, value!));
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
