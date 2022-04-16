import 'package:permission_handler/permission_handler.dart';

Future<PermissionStatus> externalFileAccess() async {
  return Permission.storage.status;
}

Future<PermissionStatus> requestPermission() async {
  return Permission.storage.request();
}

String permissionDeniedStatus(PermissionStatus status) {
  if (status == PermissionStatus.permanentlyDenied) {
    return "Storage Permission Is Permanently Denied , Please Enable it from Settings";
  }
  return "Permission Denied";
}
