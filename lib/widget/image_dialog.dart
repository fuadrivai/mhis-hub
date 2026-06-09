import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/service/api.dart';
import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final Person person;
  const ImageDialog({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  )
                ],
              ),
              const SizedBox(height: 10),
              if (person.avatar != null)
                Center(
                    child: Image.network("${Api.url}/storage/${person.avatar}"))
              else
                Image.asset(
                  "assets/images/profile.png",
                  width: 200,
                ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
