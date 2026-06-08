
import 'package:flutter/services.dart';
import 'package:kultux/core/models/legal.dart';
import 'dart:convert';

class LegalRepository {
  static final String _privacyPath = 'assets/legal/privacy.json';
  static final String _termsPath = 'assets/legal/terms.json';

  static List<Legal>? _privacyCache;
  static List<Legal>? _termsCache;

  static Future<List<Legal>> loadLegal(bool isPrivacy) async{
    if(isPrivacy && _privacyCache != null) return _privacyCache!;
    if(!isPrivacy && _termsCache != null) return _termsCache!;
    try{
      final content = await rootBundle.loadString(isPrivacy ? _privacyPath : _termsPath);
      final List<dynamic> data = json.decode(content);
      final result = data.map((e) => Legal.fromJson(e)).toList();
      if(isPrivacy) _privacyCache = result;
      else _termsCache = result;

      return result;
    }catch(e){
      return [];
    }
  }

}