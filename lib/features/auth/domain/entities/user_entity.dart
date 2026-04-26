import 'package:equatable/equatable.dart';

class LoginEntry extends Equatable {
  const LoginEntry({
    required this.date,
    required this.device,
  });

  factory LoginEntry.fromJson(Map<String, dynamic> json) => LoginEntry(
        date: DateTime.parse(json['date'] as String),
        device: json['device'] as String,
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'device': device,
      };

  final DateTime date;
  final String device;

  @override
  List<Object?> get props => [date, device];
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.photoUrl,
    this.username,
    this.weight,
    this.height,
    this.birthDate,
    this.trainingObjective,
    this.lastLoginDate,
    this.lastLoginDevice,
    this.gender,
    this.termsAcceptedAt,
    this.privacyAcceptedAt,
    this.legalVersion,
    this.marketingConsent = false,
    this.profilingConsent = false,
    this.marketingConsentUpdatedAt,
    this.profilingConsentUpdatedAt,
    this.authProviders = const [],
    this.loginHistory = const [],
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    // Migration logic for old 'name' field
    var fName = json['firstName'] as String?;
    var lName = json['lastName'] as String?;

    if (fName == null && lName == null && json['name'] != null) {
      final oldName = json['name'] as String;
      final parts = oldName.split(' ');
      fName = parts.first;
      if (parts.length > 1) {
        lName = parts.sublist(1).join(' ');
      }
    }

    return UserEntity(
      id: json['id'] as String? ?? '',
      firstName: fName ?? 'Atleta',
      lastName: lName ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      username: json['username'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      trainingObjective: json['trainingObjective'] as String?,
      lastLoginDate: json['lastLoginDate'] != null
          ? DateTime.parse(json['lastLoginDate'] as String)
          : null,
      lastLoginDevice: json['lastLoginDevice'] as String?,
      gender: json['gender'] as String?,
      termsAcceptedAt: json['termsAcceptedAt'] != null
          ? DateTime.parse(json['termsAcceptedAt'] as String)
          : null,
      privacyAcceptedAt: json['privacyAcceptedAt'] != null
          ? DateTime.parse(json['privacyAcceptedAt'] as String)
          : null,
      legalVersion: json['legalVersion'] as String?,
      marketingConsent: json['marketingConsent'] as bool? ?? false,
      profilingConsent: json['profilingConsent'] as bool? ?? false,
      marketingConsentUpdatedAt: json['marketingConsentUpdatedAt'] != null
          ? DateTime.parse(json['marketingConsentUpdatedAt'] as String)
          : null,
      profilingConsentUpdatedAt: json['profilingConsentUpdatedAt'] != null
          ? DateTime.parse(json['profilingConsentUpdatedAt'] as String)
          : null,
      authProviders: (json['authProviders'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      loginHistory: (json['loginHistory'] as List<dynamic>?)
              ?.map((e) => LoginEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'photoUrl': photoUrl,
        'username': username,
        'weight': weight,
        'height': height,
        'birthDate': birthDate?.toIso8601String(),
        'trainingObjective': trainingObjective,
        'lastLoginDate': lastLoginDate?.toIso8601String(),
        'lastLoginDevice': lastLoginDevice,
        'gender': gender,
        'termsAcceptedAt': termsAcceptedAt?.toIso8601String(),
        'privacyAcceptedAt': privacyAcceptedAt?.toIso8601String(),
        'legalVersion': legalVersion,
        'marketingConsent': marketingConsent,
        'profilingConsent': profilingConsent,
        'marketingConsentUpdatedAt':
            marketingConsentUpdatedAt?.toIso8601String(),
        'profilingConsentUpdatedAt':
            profilingConsentUpdatedAt?.toIso8601String(),
        'authProviders': authProviders,
        'loginHistory': loginHistory.map((e) => e.toJson()).toList(),
      };

  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? photoUrl;
  final String? username;
  final double? weight;
  final double? height;
  final DateTime? birthDate;
  final String? trainingObjective;
  final DateTime? lastLoginDate;
  final String? lastLoginDevice;
  final String? gender;
  final DateTime? termsAcceptedAt;
  final DateTime? privacyAcceptedAt;
  final String? legalVersion;
  final bool marketingConsent;
  final bool profilingConsent;
  final DateTime? marketingConsentUpdatedAt;
  final DateTime? profilingConsentUpdatedAt;
  final List<String> authProviders;
  final List<LoginEntry> loginHistory;

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    String? username,
    double? weight,
    double? height,
    DateTime? birthDate,
    String? trainingObjective,
    DateTime? lastLoginDate,
    String? lastLoginDevice,
    String? gender,
    DateTime? termsAcceptedAt,
    DateTime? privacyAcceptedAt,
    String? legalVersion,
    bool? marketingConsent,
    bool? profilingConsent,
    DateTime? marketingConsentUpdatedAt,
    DateTime? profilingConsentUpdatedAt,
    List<String>? authProviders,
    List<LoginEntry>? loginHistory,
    bool clearWeight = false,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
      weight: clearWeight ? null : weight ?? this.weight,
      height: height ?? this.height,
      birthDate: birthDate ?? this.birthDate,
      trainingObjective: trainingObjective ?? this.trainingObjective,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      lastLoginDevice: lastLoginDevice ?? this.lastLoginDevice,
      gender: gender ?? this.gender,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      privacyAcceptedAt: privacyAcceptedAt ?? this.privacyAcceptedAt,
      legalVersion: legalVersion ?? this.legalVersion,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      profilingConsent: profilingConsent ?? this.profilingConsent,
      marketingConsentUpdatedAt:
          marketingConsentUpdatedAt ?? this.marketingConsentUpdatedAt,
      profilingConsentUpdatedAt:
          profilingConsentUpdatedAt ?? this.profilingConsentUpdatedAt,
      authProviders: authProviders ?? this.authProviders,
      loginHistory: loginHistory ?? this.loginHistory,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        photoUrl,
        username,
        weight,
        height,
        birthDate,
        trainingObjective,
        lastLoginDate,
        lastLoginDevice,
        gender,
        termsAcceptedAt,
        privacyAcceptedAt,
        legalVersion,
        marketingConsent,
        profilingConsent,
        marketingConsentUpdatedAt,
        profilingConsentUpdatedAt,
        authProviders,
        loginHistory,
      ];
}
