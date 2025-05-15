import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      if (!isAvailable) {
        return false;
      }

      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to proceed',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }
}