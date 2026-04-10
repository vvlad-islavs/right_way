import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

class BodyProfileUseCase {
  BodyProfileUseCase(this._repo, this._errors);

  final BodyInfoRepo _repo;
  final ErrorReporter _errors;

  Future<BodyProfile> get() async {
    try {
      return await _repo.getProfile();
    } catch (e, st) {
      _errors.report(e, st);
      rethrow;
    }
  }

  Future<BodyProfile> saveField({required BodyField field, required num value}) async {
    try {
      return await _repo.saveField(field, value);
    } catch (e, st) {
      _errors.report(e, st);
      rethrow;
    }
  }
}

