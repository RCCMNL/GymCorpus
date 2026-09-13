import 'package:equatable/equatable.dart';

/// Dati sull'ultima versione pubblicata, letti da Firestore.
class AppUpdateInfo extends Equatable {
  const AppUpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.minSupportedVersionCode,
    required this.apkUrl,
    required this.changelog,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) => AppUpdateInfo(
    latestVersionCode: json['latestVersionCode'] as int,
    latestVersionName: json['latestVersionName'] as String,
    minSupportedVersionCode: json['minSupportedVersionCode'] as int,
    apkUrl: json['apkUrl'] as String,
    changelog: json['changelog'] as String? ?? '',
  );

  final int latestVersionCode;
  final String latestVersionName;
  final int minSupportedVersionCode;
  final String apkUrl;
  final String changelog;

  @override
  List<Object?> get props => [
    latestVersionCode,
    latestVersionName,
    minSupportedVersionCode,
    apkUrl,
    changelog,
  ];
}
