import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String email;
  final String photoUrl;
  final Timestamp birthday;
  final String school;
  final String gender;
  final String userRole;
  final String id;
  final String displayName;

  User({this.firstName, this.lastName, this.mobileNumber, this.email,
      this.photoUrl, this.birthday, this.school, this.gender, this.userRole, this.id, this.displayName});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        firstName: doc['firstName'],
      lastName: doc['lastName'],
      mobileNumber: doc['mobileNumber'],
      email: doc['email'],
      photoUrl: doc['photoUrl'],
      birthday: doc['birthday'],
      school: doc['school'],
      gender: doc['gender'],
      userRole: doc['userRole'],
      id: doc['id'],
      displayName: doc['displayName']
    );
  }
}
