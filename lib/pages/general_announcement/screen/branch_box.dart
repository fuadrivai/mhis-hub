import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BranchBox extends StatefulWidget {
  final List<Branch> branches;
  final Announcement announcement;
  const BranchBox(
      {super.key, required this.branches, required this.announcement});

  @override
  State<BranchBox> createState() => _BranchBoxState();
}

class _BranchBoxState extends State<BranchBox> {
  @override
  Widget build(BuildContext context) {
    return DefaultFormField(
      title: "Branch",
      textForm: TextFormField(
        controller: TextEditingController(
            text:
                "Filter (${(widget.announcement.branches ?? []).length.toString()})"),
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
                            "Select Branches",
                            style: TextStyle(),
                          ),
                        ),
                        const Divider(),
                        ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.branches.length,
                          itemBuilder: (context, index) {
                            Branch val = widget.branches[index];
                            return CheckboxListTile(
                              title: Text(val.name ?? "--"),
                              value: (widget.announcement.branches ?? [])
                                  .contains(val),
                              onChanged: (value) {
                                context
                                    .read<GeneralAnnouncementBloc>()
                                    .add(OnChangeBranches(val, value!));
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
