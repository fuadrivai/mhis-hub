import 'package:dio/dio.dart';
import 'package:fl_mhis_hr/models/model.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'restclient.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @GET("")
  Future<List<Schedule>> getSchoolCalendar();

  @GET("user/check/{email}")
  Future<bool> checkUser(@Path() String email);
  @GET("user/email/{email}")
  Future<AcademyUser> getUserByEmail(@Path() String email);
}
