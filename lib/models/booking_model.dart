class Booking {
  final String id;
  final String userId;
  final String vendorId;
  final String eventName;
  final String eventType;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String location;
  final int guestCount;
  final double amount;
  final String status;
  final String paymentStatus;
  final String notes;
  final String adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String vendorName; // For populated data

  Booking({
    required this.id,
    required this.userId,
    required this.vendorId,
    required this.eventName,
    required this.eventType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.guestCount,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    this.notes = '',
    this.adminNotes = '',
    required this.createdAt,
    required this.updatedAt,
    this.vendorName = '',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      eventName: json['eventName'] ?? '',
      eventType: json['eventType'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      location: json['location'] ?? '',
      guestCount: json['guestCount'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      notes: json['notes'] ?? '',
      adminNotes: json['adminNotes'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      vendorName: json['vendorId'] != null && json['vendorId'] is Map ? json['vendorId']['name'] ?? '' : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'vendorId': vendorId,
      'eventName': eventName,
      'eventType': eventType,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
      'guestCount': guestCount,
      'amount': amount,
      'status': status,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

