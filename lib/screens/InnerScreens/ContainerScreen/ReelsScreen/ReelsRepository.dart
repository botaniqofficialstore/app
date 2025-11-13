
import 'package:botaniqmicrogreens/constants/Constants.dart';
import '../../../../API/APIService.dart';

class ReelsRepository{
  /// This Method used to call Reels List GET API
  ///
  /// [completer] - This param used to return the API Completion handler
  Future<void> callReelsListGETApi(Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(ConstantURLs.reelListUrl, requestBody, completer);
  }

  /// This Method used to Reels Like & Dislike API
  ///
  /// [completer] - This param used to return the API Completion handler
  void callReelsLikeDisLikeApi(Map<String, dynamic> requestBody, ApiCompletionHandler completer) async {
    await APIService().callCommonPOSTApi(ConstantURLs.reelLikeDislikeUrl,requestBody, completer);
  }
}