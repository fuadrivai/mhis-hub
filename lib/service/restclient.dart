import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/model.dart';
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
  Future<LoginResponse> onLogin(@Body() data);

  @POST("password/change")
  Future<dynamic> changePassword(@Body() Map<String, dynamic> map);

  @DELETE("logout")
  Future<dynamic> onLogout();

  @GET("person")
  Future<ServerSideEmployee> getEmployee();

  @GET("person/{id}")
  Future<Employee> getEmployeeById(@Path() int id);

  @GET("attendance/schedule/{userId}")
  Future<LiveAttendanceSchedule> getLiveAttendanceSchedule(@Path() int userId);

  @GET("attendance/history")
  Future<List<AttendanceHistory>> getAttendanceHistory(
      @Body() Map<String, dynamic> map);

  @GET("payslip")
  Future<Pagination> getPaySlipData();
}
