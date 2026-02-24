class  Call {
  final int callerId;
  final int calleeId;
  final String caller;
  final String callee;
  final String type;
  final String timestamp;

  Call({
    required this.caller,
    required this.callee,
    required this.type,
    required this.timestamp, required this.callerId, required this.calleeId,
  });
  Call copyWith({
    String? caller,
    String? callee,
    String? type,
    String? timestamp,
    int? callerId,
    int? calleeId,
  }) {
    return Call(
      caller: caller ?? this.caller,
      callee: callee ?? this.callee,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      callerId: callerId ?? this.callerId,
      calleeId: calleeId ?? this.calleeId,
    );
  }
  static Call fromMap(Map<String, dynamic> map) {
    return Call(
      caller: map['caller'] ?? '',
      callee: map['callee'] ?? '',
      type: map['type'] ?? '',
      timestamp: map['created_at'] ?? '',
      callerId: map['caller_id'] ?? 0,
      calleeId: map['callee_id'] ?? 0,
    );
  }

}