import 'package:sqflite/sqflite.dart';
import 'db_factory_native.dart' if (dart.library.js_interop) 'db_factory_web.dart';

DatabaseFactory get platformDatabaseFactory => getDatabaseFactoryImpl();
