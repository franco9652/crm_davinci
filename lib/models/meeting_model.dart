class MeetingModel {
  final String id;
  final String title;
  final DateTime date;
  final String time; 
  final String duration;
  final String meetingType;
  final String? meetingLink;
  final String? address;
  final String? description;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? projectId;
  final String? projectTitle;

  MeetingModel({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.meetingType,
    this.meetingLink,
    this.address,
    this.description,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.projectId,
    this.projectTitle,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    
    final customer = json['customer'];
    final project = json['project'];
    String? cId;
    String? cName;
    if (customer is Map) {
      cId = (customer['_id'] ?? customer['id'])?.toString();
      cName = customer['name']?.toString();
      
      try {
        final phone = (customer['contactNumber'] ?? customer['phone'] ?? customer['telefono'])?.toString();
        if (phone != null && phone.isNotEmpty) {
        
        }
      } catch (_) {}
    } else if (customer != null) {
      cId = customer.toString();
    }
    String? pId;
    String? pTitle;
    if (project is Map) {
      pId = project['_id']?.toString();
      pTitle = (project['title'] ?? project['name'])?.toString();
    } else if (project != null) {
      pId = project.toString();
    }

  
    String? cPhone;
    if (customer is Map) {
      try {
        cPhone = (customer['contactNumber'] ?? customer['phone'] ?? customer['telefono'])?.toString();
      } catch (_) {}
    }

    return MeetingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      time: (json['time'] ?? '').toString(),
      duration: (json['duration'] ?? '').toString(),
      meetingType: (json['meetingType'] ?? '').toString(),
      meetingLink: json['meetingLink']?.toString(),
      address: json['address']?.toString(),
      description: json['description']?.toString(),
      customerId: cId,
      customerName: cName,
      customerPhone: cPhone,
      projectId: pId,
      projectTitle: pTitle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'meetingType': meetingType,
      'meetingLink': meetingLink,
      'address': address,
      'description': description,
      'customer': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'project': projectId,
      'projectTitle': projectTitle,
    };
  }

  Map<String, dynamic> toCreateJson() {
    final Map<String, dynamic> payload = {
      'title': title,
      'date': _dateIso(date),
      'time': time,
      'meetingType': meetingType,
    };
  
    final d = int.tryParse(duration);
    payload['duration'] = d ?? duration;
    
    if (customerId != null && customerId!.isNotEmpty) payload['customer'] = customerId;
    if (projectId != null && projectId!.isNotEmpty) payload['project'] = projectId;
    if (meetingLink != null && meetingLink!.isNotEmpty) payload['meetingLink'] = meetingLink;
    if (address != null && address!.isNotEmpty) payload['address'] = address;
    if (description != null && description!.isNotEmpty) payload['description'] = description;
    return payload;
  }

  static String _dateIso(DateTime d) {
    
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
