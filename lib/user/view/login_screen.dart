import 'dart:io'; // 플랫폼 감지를 위해 추가
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pwith/common/view/root_tab.dart';

// 로그인 화면
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // 앱 이름
              const Text(
                'Pwith',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),

              // 앱 로고
              const CircleAvatar(
                radius: 60,
                backgroundImage:
                    AssetImage('assets/images/logo.png'), // 로고 이미지 추가
              ),
              const SizedBox(height: 40),

              // 환영 메시지
              const Text(
                '플로깅과 함께하는 깨끗한 세상',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 애플 로그인 버튼 (iOS에서만 표시)
              if (Platform.isIOS)
                ElevatedButton.icon(
                  onPressed: _signInWithApple,
                  icon: const Icon(Icons.apple, size: 24),
                  label: const Text('애플 로그인', style: TextStyle(fontSize: 16)),
                  style: _buttonStyle(Colors.black),
                ),
              const SizedBox(height: 16),

              // 카카오 로그인 버튼
              ElevatedButton.icon(
                onPressed: _signInWithKakao,
                icon: const Icon(
                  Icons.chat_bubble,
                  size: 24,
                  color: Colors.yellow,
                ),
                label: const Text('카카오 로그인', style: TextStyle(fontSize: 16)),
                style: _buttonStyle(Colors.yellow.shade700),
              ),
              const SizedBox(height: 16),

              // 건너뛰기 버튼
              TextButton(
                onPressed: goToRootTab,
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),

              const Spacer(),

              // 하단 설명
              const Text(
                '계속 진행함으로써 서비스 약관과 개인정보 처리방침에 동의합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 애플 로그인
  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();

    await FirebaseAuth.instance.signInWithProvider(appleProvider).then((value) {
      print(value.user);
      goToRootTab();
    }).onError((error, stackTrace) {
      print('error $error');
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
        FirebaseAuth.instance.signInWithCredential(credential);

        await UserApi.instance.loginWithKakaoTalk().then((value) {
          print('value from kakao $value');
          goToRootTab();
        });

        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
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
      FirebaseAuth.instance.signInWithCredential(credential);

      await UserApi.instance.loginWithKakaoAccount().then((value) {
        print('value from kakao $value');
        goToRootTab();
      });

      print('카카오계정으로 로그인 성공');
    } catch (error) {
      print('카카오계정으로 로그인 실패 $error');
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
