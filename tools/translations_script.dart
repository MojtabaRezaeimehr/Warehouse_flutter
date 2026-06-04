import 'dart:convert';
import 'dart:io';

void main() async {
  //path to translations json file
  final file = File('assets/translations/en.json');

  //read the json file
  final jsonString = await file.readAsString();
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

  // Generate enum content
  final enumName = 'Translations';
  final enumContent = StringBuffer(
      '//remember to run : dart run tools/translations_script.dart \n//after modifying assets/translations/en.json to update this enum \nenum $enumName {\n');

  jsonMap.forEach((key, value) {
    enumContent.writeln('  $key,');
  });

  enumContent.writeln('}\n');

  // Write the enum to a file
  final outputFile = File('lib/utils/enums/translation_keys.dart');
  await outputFile.writeAsString(enumContent.toString());

  // ignore: avoid_print //files outside lib wont remain in release build
  print('Enum file generated successfully!');
}
