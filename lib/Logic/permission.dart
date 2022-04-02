import 'package:permission_handler/permission_handler.dart';

Future<bool> externalFileAccess() async {
  return Permission.manageExternalStorage.isGranted;
}

Future<PermissionStatus> request() async {
  return Permission.manageExternalStorage.request();
}
