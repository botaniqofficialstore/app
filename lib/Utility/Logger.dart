import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;


class Logger {
  static bool isAddLogs = true;

  ///This method used to print API details in Log.
  ///
  ///[request] - This param used to pass the http request.
  ///[response] - This param used to pass the API response
  ///[error] - This is used to pass error response
  void printApiDetails({
    http.Request? request,
    http.Response? response,
    dio.Response? dioResponse, // Added Dio Response
    String? error,
    dynamic data, //Added data object
  }) {
    if (isAddLogs) {
      String curl = "";
      if (request != null) {
        curl = "${generateCurl(request)}";
        final urlString = request.url.toString();
        if (urlString.isNotEmpty) {
          log("##Api request url is ---->> $urlString");
          final method = request.method;
          log("##Api request Method is ---->> $method");
          log("##Api request Curl is ---->> $curl");
        }
      }
      if (response != null) {
        final statusCode = response.statusCode;
        log("##Api statusCode is ---->> $statusCode");
        final responseBody =
            response.body.isNotEmpty ? response.body : "No response data";
        log("##Api Response data is ---->> $responseBody");
      }
      if (dioResponse != null) {
        final statusCode = dioResponse.statusCode;
        log("##Api statusCode is ---->> $statusCode");
        final responseBody = dioResponse.data != null
            ? dioResponse.data.toString()
            : "No response data";
        log("##Api Response data is ---->> $responseBody");
      }
      if (data != null) {
        log("##Api request data is ---->> ${data.toString()}");
      }
      if (error != null) {
        log("##Api Response Error is ---->> $error");
      }
      // DatabaseHelper().pdDao.saveApiLogs(PDApiLogger(id: Random().nextInt(10000).toString(), param: request?.body??"--", curl: curl, response: response?.body?? error??"--".toString(), createdDate:  DateConversion.getCurrentTimeFormatted("dd/MM/yyyy hh:mm ss a")));
    }
  }

  ///This method used to generate API CURL.
  ///
  ///[request] - This param used to pass the http request.
  String generateCurl(http.Request request) {
    var curl = "curl -X ${request.method} '${request.url}'";
    request.headers.forEach((key, value) {
      curl += " -H '$key: $value'";
    });
    if (request.body.isNotEmpty) {
      curl += " --data '${request.body}'";
    }
    return curl;
  }

  /// This method used to print cURL for Multipart API Details in log.
  ///
  ///[request] - This param used to pass the Multipart request to print in log.
  void printCurlCommand(http.MultipartRequest request) async {
    final command = StringBuffer();
    log("##Api request url is ---->> ${request.url}");
    log("##Api request Method is ---->> ${request.method}");
    command.write(
        "##Api request Curl is ---->>  curl -X ${request.method} '${request.url}' ");
    request.headers.forEach((key, value) {
      command.write('-H "$key: $value" ');
    });

    request.fields.forEach((key, value) {
      command.write('-F "$key=$value" ');
    });

    for (var file in request.files) {
      final filePath = file.filename;
      final contentType = file.contentType.toString();
      command.write('-F "${file.field}=@$filePath;type=$contentType" ');
    }

    log(command.toString());
  }

  /// This method used to pritn Log message.
  ///
  ///[message] - This param used to pass the message to print in log.
  void log(String message) {
    if (isAddLogs) {
      /*if (Platform.isAndroid) {
        AndroidNativePaymentService.printLogcat(message);
      } else {
        developer.log(message);
      }*/
      developer.log(message);
    }
  }

  void saveToDb(String message) {
    //log(message);
    //DatabaseHelper().pdDao.saveApiLogs(PDApiLogger(id: Random().nextInt(10000).toString(), param: message, curl: "", response: "", createdDate:  DateConversion.getCurrentTimeFormatted("dd/MM/yyyy hh:mm ss a")));
  }


}
