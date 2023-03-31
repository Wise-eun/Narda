import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:speelow/social_login.dart';

class KakaoLogin implements SocialLogin {
  @override
  Future<bool> login() async{
    try {
      //카카오톡 설치가 돼있으면
      bool isIsntalled = await isKakaoTalkInstalled();
      if (isIsntalled) {
        try{
          //카카오톡으로 로그인
          await UserApi.instance.loginWithKakaoTalk();
          return true;
        } catch (e) {
          return false;
        }
      } else {
        try {
          //카카오톡 계정부터 받아오기
          await UserApi.instance.loginWithKakaoAccount();
          return true;
        } catch (e) {
          return false;
         }
        }
      } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> logout() async{
    try {
      await UserApi.instance.unlink();
      return true;
    } catch(error) {
      return false;
    }
  }

}