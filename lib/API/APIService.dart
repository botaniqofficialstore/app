
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utility/Logger.dart';
import '../Utility/PreferencesManager.dart';
import 'CommonAPI.dart';

typedef ApiCompletionHandler = void Function(
    int statuscode, Map<String, dynamic> response);

class APIService {
  static const Duration timeOutDuration =  Duration(seconds: 30);
  static const Duration postPutTimeOutDuration =  Duration(seconds: 15);


  //MARK: - POST API
  ///This method used to handle POST API.
  Future<void> callCommonPOSTApi(
      String url, dynamic body, ApiCompletionHandler completionHandler,
      {bool isEncoded = false, bool isAccessTokenNeeded = true}) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      if (isAccessTokenNeeded) 'Authorization': 'Bearer $accessToken'
    };

    var request = http.Request('POST', Uri.parse(url))
      ..headers.addAll(headers)
      ..body = isEncoded ? body : jsonEncode(body);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });

      Logger().printApiDetails(response: response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
        completionHandler(response.statusCode, jsonDecode(response.body));
      } else {
        final retryResponse = await http.post(Uri.parse(url),
            headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }
    } catch (e) {
      try{
        final retryResponse = await http.post(Uri.parse(url),
            headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200 || retryResponse.statusCode == 201) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }catch(e){
        Logger().printApiDetails(error: e.toString());
        completionHandler(500, {'message': e.toString()});
      }
    }
  }



  //MARK: - POST API
  ///This method used to handle POST API Without body.
  Future<void> callCommonPOSTApiWithoutBody(
      String url, ApiCompletionHandler completionHandler,
      {bool isEncoded = false, bool isAccessTokenNeeded = true}) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      if (isAccessTokenNeeded) 'Authorization': 'Bearer $accessToken'
    };

    var request = http.Request('POST', Uri.parse(url))
      ..headers.addAll(headers);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.post(Uri.parse(url),
          headers: headers).timeout(postPutTimeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });

      Logger().printApiDetails(response: response);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
        completionHandler(response.statusCode, jsonDecode(response.body));
      } else {
        final retryResponse = await http.post(Uri.parse(url),
            headers: headers).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }
    } catch (e) {
      try{
        final retryResponse = await http.post(Uri.parse(url),
            headers: headers).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }catch(e){
        Logger().printApiDetails(error: e.toString());
        completionHandler(500, {'message': e.toString()});
      }
    }
  }




  //MARK: - GET API
  ///This method used to handle GET API.
  Future<void> callCommonGETApi(
      String url, ApiCompletionHandler completionHandler,
      {bool isAccessTokenNeeded = true}) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      if(isAccessTokenNeeded) 'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(url))..headers.addAll(headers);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.get(Uri.parse(url), headers: headers).timeout(timeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });
      Logger().printApiDetails(response: response);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
      } else {
        completionHandler(response.statusCode, jsonDecode(response.body));
      }
    } catch (e) {
      Logger().printApiDetails(error: e.toString());
      completionHandler(500, {'exception': e.toString()});
    }
  }

  //MARK: - PUT API
  ///This method used to handle PUT API.
  Future<void> callCommonPUTApi(
      String url, dynamic body, ApiCompletionHandler completionHandler,
      {bool isEncoded = false, bool isAccessTokenNeeded = true}) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      if(isAccessTokenNeeded) 'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('PUT', Uri.parse(url))
      ..headers.addAll(headers)
      ..body = isEncoded ? body : jsonEncode(body);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.put(Uri.parse(url),
          headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });

      Logger().printApiDetails(response: response);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
        completionHandler(response.statusCode, jsonDecode(response.body));
      } else {
        final retryResponse = await http.put(Uri.parse(url),
            headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }
    } catch (e) {
      try{
        final retryResponse = await http.put(Uri.parse(url),
            headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(postPutTimeOutDuration, onTimeout: () {
          return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
        });
        if (retryResponse.statusCode == 200) {
          final responseData = jsonDecode(retryResponse.body);
          completionHandler(200, responseData);
        } else if (retryResponse.statusCode == 401) {
          CommonAPI().callRefreshTokenAPI();
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        } else {
          completionHandler(retryResponse.statusCode, jsonDecode(retryResponse.body));
        }
      }catch(e){
        Logger().printApiDetails(error: e.toString());
        completionHandler(500, {'exception': e.toString()});
      }
    }
  }

  //MARK: - DELETE API
  ///This method used to handle DELETE API.
  Future<void> callCommonDELETEApi(
      String url, dynamic body, ApiCompletionHandler completionHandler,
      {bool isEncoded = false}) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('DELETE', Uri.parse(url))
      ..headers.addAll(headers)
      ..body = isEncoded ? body : jsonEncode(body);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.delete(Uri.parse(url),
          headers: headers, body: isEncoded ? body : jsonEncode(body)).timeout(timeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });

      Logger().printApiDetails(response: response);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
        completionHandler(response.statusCode, jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ??
            "Something Went wrong Please Try again Later.";
        completionHandler(response.statusCode, {'error': errorMessage});
      }
    } catch (e) {
      Logger().printApiDetails(error: e.toString());
      completionHandler(500, {'exception': e.toString()});
    }
  }

  //MARK: - DELETE API
  ///This method used to handle DELETE API.
  Future<void> callCommonDELETEApiWithoutBody(
      String url, ApiCompletionHandler completionHandler,
      ) async {
    final manager = await PreferencesManager.getInstance();
    final accessToken = manager.getStringValue(PreferenceKeys.accessToken);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('DELETE', Uri.parse(url))
      ..headers.addAll(headers);

    Logger().printApiDetails(request: request);
    try {
      final response = await http.delete(Uri.parse(url),
          headers: headers).timeout(timeOutDuration, onTimeout: () {
        return http.Response(jsonEncode({'message': 'Server Time out'}), 500);
      });

      Logger().printApiDetails(response: response);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        completionHandler(200, responseData);
      } else if (response.statusCode == 401) {
        CommonAPI().callRefreshTokenAPI();
        completionHandler(response.statusCode, jsonDecode(response.body));
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ??
            "Something Went wrong Please Try again Later.";
        completionHandler(response.statusCode, {'error': errorMessage});
      }
    } catch (e) {
      Logger().printApiDetails(error: e.toString());
      completionHandler(500, {'exception': e.toString()});
    }
  }

}