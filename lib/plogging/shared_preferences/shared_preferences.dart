import 'package:pwith/plogging/model/plogging_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> savePloggingData(PloggingPlayModel model) async {
  final prefs = await SharedPreferences.getInstance();
  String jsonData = jsonEncode(model.toJson()); // JSON 직렬화
  await prefs.setString('plogging_data', jsonData);
  print('Plogging 데이터가 저장되었습니다.');
}

Future<PloggingPlayModel?> loadPloggingData() async {
  final prefs = await SharedPreferences.getInstance();
  String? jsonData = prefs.getString('plogging_data');

  if (jsonData != null) {
    Map<String, dynamic> jsonMap = jsonDecode(jsonData);
    return PloggingPlayModel.fromJson(jsonMap);
  }
  return null; // 저장된 데이터가 없을 경우
}

Future<void> removePloggingData() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('plogging_data');
}
