class Call {
  final String callerId;
  final String callerName;
  final String callerImg;
  final String receiverId;
  final String receiverName;
  final String receiverImg;
  final String callId;
  final bool hasDialled;

  Call({
    required this.callerId,
    required this.callerName,
    required this.callerImg,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImg,
    required this.callId,
    required this.hasDialled,
  });

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerImg': callerImg,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverImg': receiverImg,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerImg: map['callerImg'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverImg: map['receiverImg'] ?? '',
      callId: map['callId'] ?? '',
      hasDialled: map['hasDialled'] ?? false,
    );
  }
}
