import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/pages/general_announcement/bloc/general_announcement_bloc.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class OrganizationBox extends StatefulWidget {
  final Announcement announcement;
  final List<Organization> organizations;
  const OrganizationBox(
      {super.key, required this.announcement, required this.organizations});

  @override
  State<OrganizationBox> createState() => _OrganizationBoxState();
}

class _OrganizationBoxState extends State<OrganizationBox> {
  @override
  Widget build(BuildContext context) {
    return DefaultFormField(
      title: "Organization",
      textForm: TextFormField(
        controller: TextEditingController(
            text:
                "Filter (${(widget.announcement.organizations ?? []).length.toString()})"),
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
                            "Select Organizations",
                            style: TextStyle(),
                          ),
                        ),
                        const Divider(),
                        ListView.builder(
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.organizations.length,
                          itemBuilder: (context, index) {
                            Organization val = widget.organizations[index];
                            return CheckboxListTile(
                              title: Text(val.name ?? "--"),
                              value: (widget.announcement.organizations ?? [])
                                  .contains(val),
                              onChanged: (value) {
                                context
                                    .read<GeneralAnnouncementBloc>()
                                    .add(OnChangeOrganization(val, value!));
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
