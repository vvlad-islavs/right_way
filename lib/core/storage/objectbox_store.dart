import 'package:right_way/objectbox.g.dart';

class ObjectBoxStore {
  ObjectBoxStore._(this.store);

  final Store store;

  static Future<ObjectBoxStore> create() async {
    final store = await openStore();
    return ObjectBoxStore._(store);
  }
}

