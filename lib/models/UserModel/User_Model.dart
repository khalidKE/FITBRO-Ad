class UserModel
{
  String? userName;
  String? email;
  String? profileImage;
  String? uid;

  UserModel({this.userName, this.email, this.profileImage, this.uid});

  UserModel.fromJason(Map<String,dynamic>json){
    userName=json["UserName"];
    email=json["Email"];
    profileImage=json["profileImage"];
    uid = json["uid"];

  }


}