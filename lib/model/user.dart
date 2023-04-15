class RiderUser{
  String userId;
  String userPw;
  String userPhoneNum;
  String userName;

  RiderUser(this.userId, this.userPw, this.userPhoneNum, this.userName);

  factory RiderUser.fromJson(Map<String,dynamic> json) => RiderUser(
    json['userId'] as String,
    json['userPw'] as String,
    json['userPhoneNum'] as String,
    json['userName'] as String,
  );

  Map<String, dynamic> toJson() =>{
    'userId' : userId,
    'userPw' : userPw,
    'userPhoneNum' : userPhoneNum,
    'userName' : userName
  };
}