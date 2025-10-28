import 'package:injectable/injectable.dart';

import '../../data/model/response_model.dart';
import '../../data/remote/notebook_client.dart';

@singleton
class NotebookRepo {
  final Client _client;

  NotebookRepo(this._client);

  Stream<ResponseModel> response() {
    return _client.response();
  }

  void request(String code) {
    _client.request(code);
  }
}
