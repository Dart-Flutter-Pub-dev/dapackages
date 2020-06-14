#!/usr/bin/env dart
library dapackages;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final File file = File(args[0]);
  final List<Dependency> dependencies =
      await getDependencies(file, 'dependencies');
  final List<Dependency> devDependencies =
      await getDependencies(file, 'dev_dependencies');
  dependencies.addAll(devDependencies);

  await updateDependencies(dependencies);
  await updateFile(file, dependencies);
}

Future<List<Dependency>> getDependencies(File file, String section) async {
  final List<Dependency> list = <Dependency>[];

  final String content = await file.readAsString();
  final dynamic yaml = loadYaml(content);
  final YamlMap dependencies = yaml[section];

  if (dependencies != null) {
    for (final MapEntry<dynamic, dynamic> entry in dependencies.entries) {
      if (entry.value is String) {
        final String name = entry.key.toString();
        final String value = entry.value.toString();

        if (name.isNotEmpty &&
            value.isNotEmpty &&
            !value.startsWith('>') &&
            !value.startsWith('<') &&
            value.startsWith('^')) {
          list.add(Dependency(name, value));
        }
      }
    }
  }

  return list;
}

Future<void> updateDependencies(List<Dependency> list) async {
  for (int i = 0; i < list.length; i++) {
    final Dependency dependency = list[i];

    if (i > 0) {
      stdout.write('\r');
    }

    stdout.write('Updating dependency ${i + 1}/${list.length}');

    final String lastVersion = await getLatestVersion(dependency.name);
    dependency.update(lastVersion);
  }

  stdout.writeln();
}

Future<String> getLatestVersion(String name) async {
  final Response response =
      await get('https://pub.dartlang.org/api/packages/$name');
  final dynamic json = jsonDecode(response.body);

  return json['latest']['version'];
}

Future<void> updateFile(File file, List<Dependency> list) async {
  String yaml = await file.readAsString();

  for (final Dependency dependency in list) {
    if (dependency.hasNewVersion) {
      final String search = '${dependency.name}: ${dependency.currentVersion}';
      final String replace = '${dependency.name}: ${dependency.newVersion}';

      yaml = yaml.replaceFirst(search, replace);
    }
  }

  file.writeAsStringSync(yaml);
}

class Dependency {
  final String name;
  final String currentVersion;
  String newVersion;

  Dependency(this.name, this.currentVersion) : newVersion = currentVersion;

  bool get hasNewVersion => currentVersion != newVersion;

  void update(String version) {
    if (currentVersion.startsWith('^')) {
      newVersion = '^';
    }

    newVersion += version;
  }

  @override
  String toString() {
    return '$name $currentVersion $newVersion';
  }
}
