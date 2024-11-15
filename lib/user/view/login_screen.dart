import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwith/common/const/colors.dart';
import 'package:pwith/common/layout/default_layout.dart';
import 'package:pwith/common/view/root_tab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),

              // 앱 로고
              Image.asset(
                'assets/images/logo.png',
                height: 180,
                width: 180,
              ),

              const Spacer(),

              // 애플 로그인 버튼 (iOS에서만 표시)
              if (Platform.isIOS)
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signInWithApple,
                    style: _buttonStyle(Colors.black).copyWith(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.apple, size: 27),
                        Text('Apple로 로그인', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 0),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 카카오 로그인 버튼
              InkWell(
                onTap: _signInWithKakao,
                child: Image.asset(
                  'assets/images/kakao_login.png',
                  height: 60,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 0),

              // 건너뛰기 버튼
              TextButton(
                onPressed: goToRootTab,
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 애플 로그인
  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();

    await FirebaseAuth.instance
        .signInWithProvider(appleProvider)
        .then((credential) async {
      final user = credential.user;
      if (user != null) {
        await _saveUserToFirestore(user);
        goToRootTab();
      }
    }).onError((error, stackTrace) {
      print('애플 로그인 에러: $error');
    });
  }

  // 카카오 로그인
  Future<void> _signInWithKakao() async {
    if (await isKakaoTalkInstalled()) {
      try {
        final provider = OAuthProvider("oidc.kakao");
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        final credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          await _saveUserToFirestore(user);
          goToRootTab();
        }

        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패: $error');
        if (error is PlatformException && error.code == 'CANCELED') return;
        _kakaoAccountLogin();
      }
    } else {
      _kakaoAccountLogin();
    }
  }

  // 카카오 계정 로그인
  Future<void> _kakaoAccountLogin() async {
    try {
      final provider = OAuthProvider("oidc.kakao");
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      final credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
        goToRootTab();
      }

      print('카카오계정으로 로그인 성공');
    } catch (error) {
      print('카카오계정으로 로그인 실패: $error');
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    final usersRef = FirebaseFirestore.instance.collection('users');
    final userDoc = usersRef.doc(user.uid);

    final userData = {
      'uid': user.uid,
      'nickname': user.displayName ?? '플린이',
      'ploggingLevel': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'image': null,
    };

    try {
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set(userData);
        print('Firestore에 사용자 데이터 저장 완료');
      } else {
        print('사용자가 이미 Firestore에 존재합니다.');
      }
    } catch (e) {
      print('Firestore에 사용자 데이터 저장 실패: $e');
    }
  }

  // 루트탭으로 이동
  void goToRootTab() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const RootTab(),
      ),
    );
  }

  // 버튼 스타일 지정
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: color,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
