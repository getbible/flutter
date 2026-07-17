import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openDatabaseExecutor() async {
  final WasmDatabaseResult result = await WasmDatabase.open(
    databaseName: 'getbible_life',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
}

Future<QueryExecutor> openMemoryDatabaseExecutor() async {
  final WasmDatabaseResult result = await WasmDatabase.open(
    databaseName: 'getbible_life_test',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
}
