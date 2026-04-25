with open('lib/main.dart', 'r') as f:
    c = f.read()

c = c.replace(""import 'package:flutter_native_splash/flutter_native_splash.dart';"", ""import 'package:flutter_dotenv/flutter_dotenv.dart';\nimport 'package:flutter_native_splash/flutter_native_splash.dart';"")
c = c.replace(""FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);"", ""FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);\n  \n  await dotenv.load(fileName: '.env');"")

with open('lib/main.dart', 'w') as f:
    f.write(c)

with open('lib/features/auth/data/repositories/auth_repository_impl.dart', 'r') as f:
    c = f.read()

c = c.replace(""import 'package:google_sign_in/google_sign_in.dart';"", ""import 'package:flutter_dotenv/flutter_dotenv.dart';\nimport 'package:google_sign_in/google_sign_in.dart';"")

old_update_login = '''  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
    final device = await _getDeviceInfo();
    final updatedUser = user.copyWith(
      lastLoginDate: DateTime.now(),
      lastLoginDevice: device,
    );
    // Silent update to remote and local
    unawaited(_remoteDataSource.saveUserProfile(updatedUser));
    unawaited(_localDataSource.saveUserSession(updatedUser));
    return updatedUser;
  }'''

new_update_login = '''  Future<UserEntity> _updateLoginHistory(UserEntity user) async {
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
  }'''

c = c.replace(old_update_login, new_update_login)

old_google_signin = '''      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId:
            '996703301991-gap14vk81ourfhvkaftpnf8ntvc0g68c.apps.googleusercontent.com',
      );'''

new_google_signin = '''      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
      );'''

c = c.replace(old_google_signin, new_google_signin)

with open('lib/features/auth/data/repositories/auth_repository_impl.dart', 'w') as f:
    f.write(c)


with open('lib/features/training/presentation/bloc/training_bloc.dart', 'r') as f:
    c = f.read()

old_weight = '''          final newLatestWeight =
              updatedLogs.isNotEmpty ? updatedLogs.first.weight : 0.0;
          authRepository.updateProfileDetails(weight: newLatestWeight);
        }'''

new_weight = '''          final newLatestWeight =
              updatedLogs.isNotEmpty ? updatedLogs.first.weight : 0.0;
          await authRepository.updateProfileDetails(weight: newLatestWeight);
        }'''

c = c.replace(old_weight, new_weight)

with open('lib/features/training/presentation/bloc/training_bloc.dart', 'w') as f:
    f.write(c)

print('Patch applied successfully')
