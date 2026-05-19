import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/job_postion.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:fl_mhis_hr/models/v2/attendance.dart';
import 'package:fl_mhis_hr/models/v2/attendance_log.dart';
import 'package:fl_mhis_hr/models/v2/employee.dart';
import 'package:fl_mhis_hr/models/v2/timeoff.dart';
import 'package:retrofit/retrofit.dart';

part 'restclient.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("school/calendar")
  Future<List<SchoolCalendar>> getSchoolCalendar();

  @GET("newsletter")
  Future<List<Newsletter>> getNewsletter();

  @GET("")
  Future<dynamic> academyLogin();

  @GET("user/check/{email}")
  Future<bool> checkUser(@Path() String email);

  @POST("login")
  // ignore: strict_top_level_inference
  Future<LoginResponse> onLogin(@Body() data);

  @POST("attendance/live")
  Future<AttendanceLog> postLiveAttendance(
      @Body() LiveAttendance liveAttendance);

  @GET("attendance/history")
  Future<List<Attendance>> getAttendaceHistories(
      @Body() Map<String, dynamic> map);

  @POST("password/change")
  Future<dynamic> changePassword(@Body() Map<String, dynamic> map);

  @DELETE("logout")
  Future<dynamic> onLogout();

  @GET("person")
  Future<ServerSideEmployee> getEmployee();

  @GET("person/{id}")
  Future<EmployeeOld> getEmployeeById(@Path() int id);

  @GET("attendance/schedule/{userId}")
  Future<LiveAttendanceSchedule> getLiveAttendanceSchedule(@Path() int userId);

  @GET("attendance/history")
  Future<List<AttendanceHistory>> getAttendanceHistory(
      @Body() Map<String, dynamic> map);

  @GET("payslip")
  Future<Pagination> getPaySlipData();

  @GET("category")
  Future<List<AnnouncementCategory>> getAllCategory();

  @POST("announcement")
  Future<Announcement> postAnnouncement(@Body() Announcement announcement);

  @GET("announcement")
  Future<List<Announcement>> getAnnouncement();

  @GET("branch")
  Future<List<Branch>> getAllBranch();

  @GET("organization")
  Future<List<Organization>> getAllOrganization();

  @GET("position")
  Future<List<JobPosition>> getAllJobPosition();

  @GET("level")
  Future<List<JobLevel>> getAllJobLevel();

  @POST("absent")
  Future<PostPrayer> postPrayer(@Body() PostPrayer post);

  @GET("absent/filter")
  Future<List<PostPrayer>> getPrayerHistory(@Body() Map<String, dynamic> post);

  @GET("kpi")
  Future<Kpi> getKpi();

  @GET("timeoff")
  Future<List<Timeoff>> getTimeoffs();

  @GET("employee/user/{id}")
  Future<Employee> employeeById(@Path() int id);

  @POST("time/request")
  @MultiPart()
  Future<dynamic> postTimeoffMultipart(
    @Part(name: 'requester_employee_id') int requesterEmployeeId,
    @Part(name: 'timeoff_id') int timeoffId,
    @Part(name: 'note') String? note,
    @Part(name: 'dynamic_fields') String? dynamicFields,
    @Part(name: 'attachments[]') List<MultipartFile>? attachments,
  );

  @GET("time/request/user")
  Future<dynamic> getUserTimeoff();
}
