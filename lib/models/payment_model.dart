class Payment {
  final String id;
  final String userId;
  final String bookingId;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String bookingName; // For populated data

  Payment({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId = '',
    required this.status,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.bookingName = '',
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      bookingName: json['bookingId'] != null && json['bookingId'] is Map ? json['bookingId']['eventName'] ?? '' : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'bookingId': bookingId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

