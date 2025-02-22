// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class FriendMOdel {
  String? friendName;
  String? friendId;
  String? userID;
  String? id;
  FriendMOdel({
    this.friendName,
    this.friendId,
    this.userID,
    this.id,
  });

  FriendMOdel copyWith({
    String? friendName,
    String? friendId,
    String? userID,
    String? id,
  }) {
    return FriendMOdel(
      friendName: friendName ?? this.friendName,
      friendId: friendId ?? this.friendId,
      userID: userID ?? this.userID,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'friendName': friendName,
      'friendId': friendId,
      'userID': userID,
      'id': id,
    };
  }

  factory FriendMOdel.fromMap(Map<String, dynamic> map) {
    return FriendMOdel(
      friendName:
          map['friendName'] != null ? map['friendName'] as String : null,
      friendId: map['friendId'] != null ? map['friendId'] as String : null,
      userID: map['userID'] != null ? map['userID'] as String : null,
      id: map['id'] != null ? map['id'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FriendMOdel.fromJson(String source) =>
      FriendMOdel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FriendMOdel(friendName: $friendName, friendId: $friendId, userID: $userID, id: $id)';
  }

  @override
  bool operator ==(covariant FriendMOdel other) {
    if (identical(this, other)) return true;

    return other.friendName == friendName &&
        other.friendId == friendId &&
        other.userID == userID &&
        other.id == id;
  }

  @override
  int get hashCode {
    return friendName.hashCode ^
        friendId.hashCode ^
        userID.hashCode ^
        id.hashCode;
  }
}
