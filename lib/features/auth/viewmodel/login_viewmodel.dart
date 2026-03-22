import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import '../model/login_model.dart';
import '../../../core/services/token_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorage _tokenStorage;

  LoginViewModel(this._authService, this._tokenStorage);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // The backend expects the password to be AES-encrypted using the CryptoJS algorithm.
      // CryptoJS uses OpenSSL EVP_BytesToKey to derive the key/iv from a passphrase.
      // We will encrypt the password using AES/CBC/PKCS7 exactly as CryptoJS does natively:
      // using the passphrase 'pass@1002Word'

      final keyString = 'pass@1002Word';

      // In Javascript, CryptoJS.AES.encrypt('password', 'passphrase') automatically generates
      // a random salt and derives the Key and IV. We need to do the same in Dart.

      // Generate 8 bytes of secure random salt
      final salt = encrypt.SecureRandom(8).bytes;

      // Derive 256-bit Key and 128-bit IV using OpenSSL's EVP_BytesToKey algorithm from the passphrase + salt
      final keyNdIV = _deriveKeyAndIV(keyString, salt);
      final key = encrypt.Key(keyNdIV.sublist(0, 32));
      final iv = encrypt.IV(keyNdIV.sublist(32, 48));

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
      final encryptedBytes = encrypter.encrypt(password, iv: iv).bytes;

      // Construct the final CryptoJS compatible base64 string
      // Format: "Salted__" (8 bytes) + salt (8 bytes) + encrypted data
      final saltedPrefix = utf8.encode("Salted__");
      final combinedPayload = Uint8List.fromList([
        ...saltedPrefix,
        ...salt,
        ...encryptedBytes,
      ]);
      final encryptedPasswordBase64 = base64.encode(combinedPayload);

      final request = LoginRequest(
        username: username,
        password: encryptedPasswordBase64,
        rememberMe: false,
        deviceType: "MOBILE",
      );

      final response = await _authService.login(request);

      if (response.token.isNotEmpty) {
        await _tokenStorage.saveToken(response.token);

        // Save the derived role (admin/user) depending on the isAdmin flag
        await _tokenStorage.saveUserRole(response.user.role);

        // Save the user id to be utilized for fetching reports later
        await _tokenStorage.saveUserId(response.user.id);

        // Save metadata headers required by middleware logic
        await _tokenStorage.saveCompanyName(response.user.companyName);
        await _tokenStorage.saveCompanyType(response.user.companyType);
        await _tokenStorage.saveUsername(response.user.username);

        if (response.user.profileLogo != null &&
            response.user.profileLogo!.isNotEmpty) {
          await _tokenStorage.saveProfileLogo(response.user.profileLogo!);
        }

        await _tokenStorage.saveModuleAccess(response.user.moduleAccess);


        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Server did not return an authentication token');
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper method mirroring OpenSSL EVP_BytesToKey used inherently by CryptoJS
  Uint8List _deriveKeyAndIV(String passphrase, Uint8List salt) {
    var passwordBytes = utf8.encode(passphrase);
    var concatenatedHashes = <int>[];
    var currentHash = <int>[];
    bool enoughBytesForKey = false;

    // We need 32 bytes for the Key and 16 bytes for IV (48 total bytes)
    while (!enoughBytesForKey) {
      if (currentHash.isNotEmpty) {
        currentHash = md5.convert([
          ...currentHash,
          ...passwordBytes,
          ...salt,
        ]).bytes;
      } else {
        currentHash = md5.convert([...passwordBytes, ...salt]).bytes;
      }
      concatenatedHashes.addAll(currentHash);
      if (concatenatedHashes.length >= 48) {
        enoughBytesForKey = true;
      }
    }
    return Uint8List.fromList(concatenatedHashes);
  }
}
