import 'package:easy_localization/easy_localization.dart';
import 'package:meet_queue_volunteer/api_base_helper.dart';
import 'package:meet_queue_volunteer/response/user_response.dart';

import '../constants.dart';

class UserRepository {
  // final String baseUrl = 'https://api.queue.freshturfengineering.com/';
  ApiBaseHelper _apiHelper = ApiBaseHelper();

  // Future<List<User>> getUsers() async{
  
  //   final response = await _helper.get("user");
  //   if (response.statusCode == 200)
  //     return UserResponse.fromJson(response.body).data;
  //   else {
  //     print(response.body);
  //     throw Exception('Error from getUsers');
  //   }
  // }

  Future<UserResponse> searchUser(String nric) async{
  
    Map reqBody = {
      "nric": nric
    };

    final response = await _apiHelper.post("user/search", reqBody);
    return UserResponse.fromJson(response);
  }

  Future<UserResponse> updateUser(UserData userData) async{
  
    String uid = userData.uid;
    if (!["", null].contains(uid)) {
      Map reqBody = userData.toJson();
      // Remove non-modifiable fields
      reqBody.removeWhere((key, value) => key == "nric");
      reqBody.removeWhere((key, value) => key == "email");
      reqBody.removeWhere((key, value) => key == "uid");
      reqBody.removeWhere((key, value) => key == "otp");
      reqBody.removeWhere((key, value) => key == "accessToken");
      reqBody.removeWhere((key, value) => key == "verificationCode");
      reqBody.removeWhere((key, value) => key == "authServer");

      final response = await _apiHelper.patch("user/" + uid, reqBody);
      return UserResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<UserResponse> createUser(UserData userData) async{
  
    String uid = userData.uid;
    if (["", null].contains(uid)) {

      userData.authServer = 'freshturf';
      userData.createdAt = DateTime.now(); // to prevent error calling toJson
      // Convert dob into ISO 8601 format (yyyy-MM-dd) as API accepts only this format
      String dob = DateFormat(DATE_ISO_8601_FORMAT).format(userData.dob);

      Map reqBody = userData.toJson();
      // Remove non-modifiable / should not exist fields
      reqBody.removeWhere((key, value) => key == "dob");
      reqBody.removeWhere((key, value) => key == "email");
      reqBody.removeWhere((key, value) => key == "otp");
      reqBody.removeWhere((key, value) => key == "accessToken");
      reqBody.removeWhere((key, value) => key == "verificationCode");
      reqBody.removeWhere((key, value) => key == "uid");
      reqBody["dob"] = dob;

      final response = await _apiHelper.post("user", reqBody);
      return UserResponse.fromJson(response);

    } else {
      return null;
    }
  }
}