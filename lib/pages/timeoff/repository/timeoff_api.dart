import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/v2/models.dart';
import 'package:fl_mhis_hr/service/api.dart';

class TimeoffApi {
  static Future<List<Timeoff>> get() async {
    final client = await Api.restClient();
    var data = client.getTimeoffs();
    return data;
  }

  static Future<Employee> getEmployeeById(int id) async {
    final client = await Api.restClient();
    var data = client.employeeById(id);
    return data;
  }

  static Future<dynamic> postTimeoff(Request approvalRequest) async {
    final dio = await Api.dioClient();

    final dynamicFields = <String, dynamic>{};
    approvalRequest.dynamicFields?.forEach((key, value) {
      dynamicFields['dynamic_fields[$key]'] = value;
    });

    final attachments = approvalRequest.attachments
        ?.map(
          (item) => MultipartFile.fromFileSync(
            item.file?.path ?? item.filePath,
            filename: item.fileName,
          ),
        )
        .toList();

    final formData = FormData.fromMap({
      'requester_employee_id': approvalRequest.requesterEmployeeId,
      'timeoff_id': approvalRequest.timeoffId,
      if (approvalRequest.note != null && approvalRequest.note!.isNotEmpty)
        'note': approvalRequest.note,
      ...dynamicFields,
      if (attachments != null && attachments.isNotEmpty)
        'attachments[]': attachments,
    });

    final response = await dio.post(
      '${Api.baseUrl}time/request',
      data: formData,
    );

    return response.data;
  }
}
