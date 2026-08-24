import 'package:fl_mhis_hr/library/constant.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/widget/widget.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jiffy/jiffy.dart';

class GeneralAnnouncementView extends StatefulWidget {
  final Announcement announcement;
  const GeneralAnnouncementView({super.key, required this.announcement});

  @override
  State<GeneralAnnouncementView> createState() =>
      _GeneralAnnouncementViewState();
}

class _GeneralAnnouncementViewState extends State<GeneralAnnouncementView> {
  Announcement ann = Announcement();
  List<String> toName = [];

  @override
  void initState() {
    ann = widget.announcement;
    if (ann.allEmployees!) {
      toName.add("All Employees");
    } else {
      for (var val in ann.branches ?? []) {
        toName.add(val.name ?? "--");
      }
      for (var val in ann.organizations ?? []) {
        toName.add(val.name ?? "--");
      }
      for (var val in ann.positions ?? []) {
        toName.add(val.name ?? "--");
      }
      for (var val in ann.jobLevels ?? []) {
        toName.add(val.name ?? "--");
      }
    }
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
        title: "Announcement",
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("From ${ann.creator?.personal?.fullname ?? '--'}"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Post To :"),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        children: toName.map((val) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: AppColors.blue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                val,
                                style: const TextStyle(color: AppColors.white),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                Text(
                    "Post on : ${Jiffy.parse(ann.publishAt!, pattern: "yyyy-MM-dd").format(pattern: "dd MMM yyyy")}"),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(ann.category?.name ?? "Uncategorized"),
                ),
                const SizedBox(height: 30),
                Text(
                  ann.title ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 20),
                Html(
                  data: ann.content ?? '',
                  onLinkTap: (url, attributes, element) async {
                    if (url == null || url.isEmpty) {
                      return;
                    }
                    await Common.launchExternalUrl(url);
                  },
                ),
                const SizedBox(height: 20),
                if (ann.link != null && ann.link!.isNotEmpty)
                  InkWell(
                    onTap: () => Common.launchExternalUrl(ann.link!),
                    child: const Text(
                      "Link",
                      style: TextStyle(color: AppColors.blue),
                    ),
                  ),
                if (ann.attachment != null && ann.attachment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Attachment",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Image.network(
                    ann.attachmentLink(),
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
