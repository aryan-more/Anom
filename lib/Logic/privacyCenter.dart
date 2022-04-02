import 'package:anom/Logic/secureio.dart';

class CustomUrls {
  late List<String> urls;
  bool customUrlsExists = false;
  Future<void> loadUrls() async {
    if (await ((await getFile("custom.urls")).exists())) {
      customUrlsExists = true;
      urls = (await read(filename: "custom.urls")).split('\n');
    }
  }

  String tostring() {
    if (customUrlsExists) {
      StringBuffer buffer = StringBuffer();
      for (String item in urls) {
        buffer.write("$item\n");
      }
      return buffer.toString();
    }
    return "";
  }

  Future<void> updateUrls(String raw) async {
    urls = raw.split('\n');
    await write(filename: "custom.urls", rawdata: raw);
  }
}
