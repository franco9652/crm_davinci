class WorkModel {
  final String? id; // Agregar este campo
  final List<String> userId;
  final String name;
  final String address;
  final String startDate;
  final String? description; 
  final String? endDate;
  final double budget;
  final String statusWork;
  final String workUbication;
  final String projectType;
  final List<String> documents;
  final List<String> employeeInWork;
  final String customerName;
  String? number;

  WorkModel({
    this.id, // Inicializar el campo id
    this.description,
    required this.userId,
    required this.name,
    required this.address,
    required this.startDate,
    this.endDate,
    required this.budget,
    required this.statusWork,
    required this.workUbication,
    required this.projectType,
    required this.documents,
    required this.employeeInWork,
    required this.customerName,
    this.number,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['_id'], // Asegurarte que el id venga del backend
      description: json['description'],
      name: json['name'] ?? '',
      userId: (json['userId'] is List)
          ? List<String>.from(json['userId'])
          : [json['userId'] as String],
      address: json['address'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
      budget: json['budget']?.toDouble() ?? 0.0,
      documents: json['documents'] != null
          ? List<String>.from(json['documents'])
          : [],
      employeeInWork: json['employeeInWork'] != null
          ? List<String>.from(json['employeeInWork'])
          : [],
      statusWork: json['statusWork'] ?? '',
      workUbication: json['workUbication'] ?? '',
      projectType: json['projectType'] ?? '',
      customerName: json['customerName'] ?? '',
      number: json['number'] ?? '0XXX',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Agregar el id al JSON
      'description': description,
      'name': name,
      'userId': userId,
      'address': address,
      'startDate': startDate,
      'endDate': endDate,
      'budget': budget,
      'documents': documents,
      'employeeInWork': employeeInWork,
      'statusWork': statusWork,
      'workUbication': workUbication,
      'projectType': projectType,
      'customerName': customerName,
      'number': number,
    };
  }
}
