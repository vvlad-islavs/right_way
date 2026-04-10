import 'package:right_way/core/core.dart';
import 'package:right_way/features/body_info/domain/domain.dart';

class BodyProfileUseCase {
  BodyProfileUseCase(this._repo, this._errors);

  final BodyInfoRepo _repo;
  final ErrorReporter _errors;

  Future<BodyProfile> get() => ErrorHandling.reportAndRethrow(_errors, () => _repo.getProfile());

  Future<BodyProfile> saveField({required BodyField field, required num value}) =>
      ErrorHandling.reportAndRethrow(_errors, () => _repo.saveField(field, value));
}
