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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                signInWithApple();
              },
              child: const Text('애플 로그인'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                signInWithKakao();
              },
              child: const Text('카카오 로그인'),
            ),
            ElevatedButton(
              onPressed: () {
                goToRootTab();
              },
              child: const Text('건너뛰기'),
            ),
          ],
        ),
      ),
    );
  }

  // 애플 로그인
  Future<void> signInWithApple() async {
    final appleProvider = AppleAuthProvider();

    await FirebaseAuth.instance.signInWithProvider(appleProvider).then((value) {
      print(value.user);
      goToRootTab();
    }).onError((error, stackTrace) {
      print('error $error');
    });
  }

  // 카카오 로그인
  Future<void> signInWithKakao() async {
    // 카카오톡 실행 가능 여부 확인
    // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
    if (await isKakaoTalkInstalled()) {
      try {
        // Firebase 로그인
        final provider = OAuthProvider("oidc.kakao");
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        final credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        FirebaseAuth.instance.signInWithCredential(credential);

        // 카카오 로그인
        await UserApi.instance.loginWithKakaoTalk().then((value) {
          print('value from kakao $value');
          goToRootTab();
        });

        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          // Firebase 로그인
          final provider = OAuthProvider("oidc.kakao");
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          final credential = provider.credential(
            idToken: token.idToken,
            accessToken: token.accessToken,
          );
          FirebaseAuth.instance.signInWithCredential(credential);

          // 카카오 로그인
          await UserApi.instance.loginWithKakaoAccount().then((value) {
            print('value from kakao $value');
            goToRootTab();
          });

          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        // Firebase 로그인
        final provider = OAuthProvider("oidc.kakao");
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        final credential = provider.credential(
          idToken: token.idToken,
          accessToken: token.accessToken,
        );
        FirebaseAuth.instance.signInWithCredential(credential);

        // 카카오 로그인
        await UserApi.instance.loginWithKakaoAccount().then((value) {
          print('value from kakao $value');
          goToRootTab();
        });

        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
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
}
