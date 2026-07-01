import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/storage/hive_storage.dart';

final storageProvider = Provider<HiveStorage>((ref) {
  // Expose the initialized instance. We must initialize it in main().
  throw UnimplementedError('storageProvider must be overridden in main() with the initialized HiveStorage instance.');
});
