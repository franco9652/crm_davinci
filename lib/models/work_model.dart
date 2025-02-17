class WorkModel {
  final String? id;
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
  final String? emailCustomer;
  String? number;

  WorkModel({
    this.id,
    required this.userId,
    required this.name,
    required this.address,
    required this.startDate,
    this.description,
    this.endDate,
    required this.budget,
    required this.statusWork,
    required this.workUbication,
    required this.projectType,
    required this.documents,
    required this.employeeInWork,
    required this.customerName,
    this.emailCustomer,
    this.number,
  });

  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['_id'] as String?,
      userId: (json['userId'] is List)
          ? List<String>.from(json['userId'].map((e) => e.toString()))
          : [],
      name: json['name'] ?? 'Nombre no disponible',
      address: json['address'] ?? 'Dirección no disponible',
      startDate: json['startDate'] ?? 'Fecha de inicio no disponible',
      endDate: json['endDate'] ?? 'Fecha de fin no disponible',
      budget: (json['budget'] != null)
          ? (json['budget'] is int
              ? (json['budget'] as int).toDouble()
              : json['budget'])
          : 0.0,
      documents:
          json['documents'] != null ? List<String>.from(json['documents']) : [],
      employeeInWork: json['employeeInWork'] != null
          ? List<String>.from(json['employeeInWork'])
          : [],
      statusWork: json['statusWork'] ?? 'Estado no disponible',
      workUbication: json['workUbication'] ?? 'Ubicación no especificada',
      projectType: json['projectType'] ?? 'Tipo de proyecto no disponible',
      customerName: json['customerName'] ?? 'Sin cliente',
      emailCustomer: json['emailCustomer'] ?? 'Sin email',
      number: json['number'] ?? 'T000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
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
      'emailCustomer': emailCustomer,
      'number': number,
    };
  }
}
