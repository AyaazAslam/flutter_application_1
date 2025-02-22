// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class RequestModel {
  String? senderName;
  String? senderId;
  String? reciverId;
  String? reciverName;
  String? status;
  String? requestId;
  RequestModel({
    this.senderName,
    this.senderId,
    this.reciverId,
    this.reciverName,
    this.status,
    this.requestId,
  });

  RequestModel copyWith({
    String? senderName,
    String? senderId,
    String? reciverId,
    String? reciverName,
    String? status,
    String? requestId,
  }) {
    return RequestModel(
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      reciverId: reciverId ?? this.reciverId,
      reciverName: reciverName ?? this.reciverName,
      status: status ?? this.status,
      requestId: requestId ?? this.requestId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderName': senderName,
      'senderId': senderId,
      'reciverId': reciverId,
      'reciverName': reciverName,
      'status': status,
      'requestId': requestId,
    };
  }

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      senderName:
          map['senderName'] != null ? map['senderName'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      reciverId: map['reciverId'] != null ? map['reciverId'] as String : null,
      reciverName:
          map['reciverName'] != null ? map['reciverName'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      requestId: map['requestId'] != null ? map['requestId'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestModel.fromJson(String source) =>
      RequestModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RequestModel(senderName: $senderName, senderId: $senderId, reciverId: $reciverId, reciverName: $reciverName, status: $status, requestId: $requestId)';
  }

  @override
  bool operator ==(covariant RequestModel other) {
    if (identical(this, other)) return true;

    return other.senderName == senderName &&
        other.senderId == senderId &&
        other.reciverId == reciverId &&
        other.reciverName == reciverName &&
        other.status == status &&
        other.requestId == requestId;
  }

  @override
  int get hashCode {
    return senderName.hashCode ^
        senderId.hashCode ^
        reciverId.hashCode ^
        reciverName.hashCode ^
        status.hashCode ^
        requestId.hashCode;
  }
}
