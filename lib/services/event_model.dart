class Event {
  final String? id;
  final String eventName;
  final DateTime eventDate;
  final String location;
  final double? budget;
  final String? description;
  final String category;
  final List<String>? collaborators;
  final List<Guest>? guests;
  final bool isPublic;
  final ReminderSettings? reminderSettings;
  final String? createdBy;
  final String? updatedBy;
  final String status;
  final List<Attachment>? attachments;
  final String? imageUrl;
  
  Event({
    this.id,
    required this.eventName,
    required this.eventDate,
    required this.location,
    this.budget,
    this.description,
    required this.category,
    this.collaborators,
    this.guests,
    this.isPublic = false,
    this.reminderSettings,
    this.createdBy,
    this.updatedBy,
    this.status = 'planning',
    this.attachments,
    this.imageUrl,
  });
  
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      eventName: json['eventName'],
      eventDate: DateTime.parse(json['eventDate']),
      location: json['location'],
      budget: json['budget']?.toDouble(),
      description: json['description'],
      category: json['category'] ?? 'Other',
      collaborators: json['collaborators'] != null 
          ? List<String>.from(json['collaborators']) 
          : null,
      guests: json['guests'] != null 
          ? List<Guest>.from(json['guests'].map((x) => Guest.fromJson(x))) 
          : null,
      isPublic: json['isPublic'] ?? false,
      reminderSettings: json['reminderSettings'] != null 
          ? ReminderSettings.fromJson(json['reminderSettings']) 
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      status: json['status'] ?? 'planning',
      attachments: json['attachments'] != null 
          ? List<Attachment>.from(json['attachments'].map((x) => Attachment.fromJson(x))) 
          : null,
      imageUrl: json['imageUrl'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'location': location,
      'budget': budget,
      'description': description,
      'category': category,
      'collaborators': collaborators,
      'guests': guests?.map((x) => x.toJson()).toList(),
      'isPublic': isPublic,
      'reminderSettings': reminderSettings?.toJson(),
      'status': status,
    };
  }
  
  // Convert to the format used in the existing app
  Map<String, dynamic> toAppFormat() {
    return {
      'id': id,
      'name': eventName,
      'date': '${eventDate.day}/${eventDate.month}/${eventDate.year}',
      'time': '${eventDate.hour}:${eventDate.minute.toString().padLeft(2, '0')}',
      'location': location,
      'description': description,
      'budget': budget?.toString(),
      'type': category,
      'image_url': imageUrl ?? '',
      'guests': guests?.map((g) => g.toAppFormat()).toList() ?? [],
    };
  }
  
  // Create from the app format
  factory Event.fromAppFormat(Map<String, dynamic> data) {
    // Parse date and time
    List<String> dateParts = (data['date'] as String).split('/');
    List<String> timeParts = (data['time'] as String).split(':');
    
    DateTime eventDateTime = DateTime(
      int.parse(dateParts[2]),  // year
      int.parse(dateParts[1]),  // month
      int.parse(dateParts[0]),  // day
      int.parse(timeParts[0]),  // hour
      int.parse(timeParts[1]),  // minute
    );
    
    return Event(
      eventName: data['name'],
      eventDate: eventDateTime,
      location: data['location'],
      budget: data['budget'] != null ? double.tryParse(data['budget']) : null,
      description: data['description'],
      category: data['type'] ?? 'Other',
      guests: data['guests'] != null 
          ? List<Guest>.from(data['guests'].map((x) => Guest.fromAppFormat(x))) 
          : null,
      imageUrl: data['image_url'],
    );
  }
}

class Guest {
  final String name;
  final String email;
  final String? phone;
  final String rsvpStatus;
  final bool inviteSent;
  final String source;
  final String? notes;
  
  Guest({
    required this.name,
    required this.email,
    this.phone,
    required this.rsvpStatus,
    required this.inviteSent,
    required this.source,
    this.notes,
  });
  
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      rsvpStatus: json['rsvpStatus'],
      inviteSent: json['inviteSent'],
      source: json['source'],
      notes: json['notes'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'rsvpStatus': rsvpStatus,
      'inviteSent': inviteSent,
      'source': source,
      'notes': notes,
    };
  }
  
  // Convert to the format used in the existing app
  Map<String, dynamic> toAppFormat() {
    String status;
    switch (rsvpStatus) {
      case 'confirmed':
        status = 'Confirmed';
        break;
      case 'declined':
        status = 'Declined';
        break;
      case 'maybe':
        status = 'Maybe';
        break;
      case 'pending':
        status = inviteSent ? 'Invited' : 'Not Invited';
        break;
      default:
        status = 'Not Invited';
    }
    
    return {
      'name': name,
      'email': email,
      'phone': phone ?? '',
      'status': status,
    };
  }
  
  // Create from the app format
  factory Guest.fromAppFormat(Map<String, dynamic> data) {
    String rsvpStatus;
    bool inviteSent = false;
    
    switch (data['status']) {
      case 'Confirmed':
        rsvpStatus = 'confirmed';
        inviteSent = true;
        break;
      case 'Declined':
        rsvpStatus = 'declined';
        inviteSent = true;
        break;
      case 'Maybe':
        rsvpStatus = 'maybe';
        inviteSent = true;
        break;
      case 'Invited':
        rsvpStatus = 'pending';
        inviteSent = true;
        break;
      default:
        rsvpStatus = 'pending';
        inviteSent = false;
    }
    
    return Guest(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      rsvpStatus: rsvpStatus,
      inviteSent: inviteSent,
      source: 'manual',
      notes: '',
    );
  }
}

class ReminderSettings {
  final bool reminderEnabled;
  final int reminderTime;
  final bool reminderSent;
  
  ReminderSettings({
    required this.reminderEnabled,
    required this.reminderTime,
    required this.reminderSent,
  });
  
  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      reminderEnabled: json['reminderEnabled'],
      reminderTime: json['reminderTime'],
      reminderSent: json['reminderSent'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderSent': reminderSent,
    };
  }
}

class Attachment {
  final String name;
  final String url;
  final String type;
  final int size;
  final DateTime uploadedAt;
  
  Attachment({
    required this.name,
    required this.url,
    required this.type,
    required this.size,
    required this.uploadedAt,
  });
  
  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'],
      url: json['url'],
      type: json['type'],
      size: json['size'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'url': url,
      'type': type,
      'size': size,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}