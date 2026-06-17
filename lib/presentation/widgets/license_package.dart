import 'package:flutter/foundation.dart';

class LicensePackage {
  final String packageName;
  final List<LicenseEntry> entries;

  LicensePackage({
    required this.packageName,
    required this.entries,
  });

  int get licenseCount => entries.length;
}

Future<List<LicensePackage>> getLicenses() async {
  final Map<String, List<LicenseEntry>> grouped = {};

  await for (final entry in LicenseRegistry.licenses) {
    for (final package in entry.packages) {
      grouped.putIfAbsent(package, () => []);
      grouped[package]!.add(entry);
    }
  }

  final result = grouped.entries.map((e) {
    return LicensePackage(
      packageName: e.key,
      entries: e.value,
    );
  }).toList();

  result.sort(
        (a, b) => a.packageName.compareTo(b.packageName),
  );

  return result;
}