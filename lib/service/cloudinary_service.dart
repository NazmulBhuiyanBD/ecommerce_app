import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ecommerce_app/utils/env.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const cloudName = Env.cloudName;
  static const uploadPreset = Env.uploadPreset;

  static Future<String?> uploadImage(File file) async {
    final url = "https://api.cloudinary.com/v1_1/$cloudName/image/upload";

    final request = http.MultipartRequest("POST", Uri.parse(url));
    request.fields["upload_preset"] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath("file", file.path));

    final res = await request.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      final data = jsonDecode(resBody);
      return data["secure_url"];
    } else {
      print("Cloudinary Error: $resBody");
      return null;
    }
  }
  static Future<String?> uploadBytes(Uint8List bytes) async {
  final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

  final request = http.MultipartRequest("POST", url);
  request.fields["upload_preset"] = uploadPreset;

  request.files.add(
    http.MultipartFile.fromBytes("file", bytes, filename: "upload.png"),
  );

  final res = await request.send();
  final body = await res.stream.bytesToString();

  if (res.statusCode == 200) {
    final data = jsonDecode(body);
    return data["secure_url"];
  }
  print("Cloudinary Error: $body");
  return null;
}

}
