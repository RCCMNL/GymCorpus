const fs = require('fs');

try {
// main.dart
let c = fs.readFileSync('lib/main.dart', 'utf8');
c = c.replace("import 'package:flutter_native_splash/flutter_native_splash.dart';", "import 'package:flutter_dotenv/flutter_dotenv.dart';\nimport 'package:flutter_native_splash/flutter_native_splash.dart';");
c = c.replace("FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);", "FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);\n  \n  await dotenv.load(fileName: \".env\");");
fs.writeFileSync('lib/main.dart', c);

// auth_repository_impl.dart
c = fs.readFileSync('lib/features/auth/data/repositories/auth_repository_impl.dart', 'utf8');
c = c.replace("import 'package:google_sign_in/google_sign_in.dart';", "import 'package:flutter_dotenv/flutter_dotenv.dart';\nimport 'package:google_sign_in/google_sign_in.dart';");

const old_update_login = `  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
    final device = await _getDeviceInfo();
    final updatedUser = user.copyWith(
      lastLoginDate: DateTime.now(),
      lastLoginDevice: device,
    );
    // Silent update to remote and local
    unawaited(_remoteDataSource.saveUserProfile(updatedUser));
    unawaited(_localDataSource.saveUserSession(updatedUser));
    return updatedUser;
  }`;

const new_update_login = `  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
    final device = await _getDeviceInfo();
    final updatedUser = user.copyWith(
      lastLoginDate: DateTime.now(),
      lastLoginDevice: device,
    );
    try {
      await _remoteDataSource.saveUserProfile(updatedUser).timeout(const Duration(seconds: 5));
    } catch (_) {}
    try {
      await _localDataSource.saveUserSession(updatedUser);
    } catch (_) {}
    return updatedUser;
  }`;
c = c.replace(old_update_login, new_update_login);

const old_google_signin = `      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId:
            '996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com',
      );`;

const new_google_signin = `      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );`;
c = c.replace(old_google_signin, new_google_signin);
fs.writeFileSync('lib/features/auth/data/repositories/auth_repository_impl.dart', c);

// training_bloc.dart
c = fs.readFileSync('lib/features/training/presentation/bloc/training_bloc.dart', 'utf8');
const old_weight = `          final newLatestWeight =
              updatedLogs.isNotEmpty ? updatedLogs.first.weight : 0.0;
          authRepository.updateProfileDetails(weight: newLatestWeight);
        }`;
const new_weight = `          final newLatestWeight =
              updatedLogs.isNotEmpty ? updatedLogs.first.weight : 0.0;
          await authRepository.updateProfileDetails(weight: newLatestWeight);
        }`;
c = c.replace(old_weight, new_weight);
fs.writeFileSync('lib/features/training/presentation/bloc/training_bloc.dart', c);

console.log('done');
} catch (e) {
  console.error(e);
}
