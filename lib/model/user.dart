class User{
  String userId;
  String userPw;
  String userPhoneNum;
  String userName;

  User(this.userId, this.userPw, this.userPhoneNum, this.userName);

  factory User.fromJson(Map<String,dynamic> json) => User(
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