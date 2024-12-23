class WorkModel {
  final List<String> userId;
 // Identificador del usuario asociado (cliente)
  final String name; // Nombre del proyecto
  final String address; // Dirección del proyecto
  final String startDate; // Fecha de inicio del proyecto (formato ISO 8601)
  final String? endDate; // Fecha de fin del proyecto (opcional, formato ISO 8601)
  final double budget; // Presupuesto del proyecto
  final String statusWork; // Estado del proyecto (activo, pausado, inactivo)
  final String workUbication; // Ubicación del proyecto (coordenadas o descripción)
  final String projectType;
   final List<String> documents; // Esto debe ser una lista
  final List<String> employeeInWork; // Tipo de proyecto (residencial, comercial, industrial)

  WorkModel({
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
    required this.employeeInWork
  });

  // Convertir el modelo a un mapa JSON para enviar al backend
  factory WorkModel.fromJson(Map<String, dynamic> json) {
  return WorkModel(
    name: json['name'] ?? '',
    userId: (json['userId'] is List)
        ? List<String>.from(json['userId'])
        : [json['userId'] as String], // Si no es lista, lo convertimos a lista
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
  );
}

Map<String, dynamic> toJson() {
  return {
    'name': name,
    'userId': userId, // Enviamos como lista
    'address': address,
    'startDate': startDate,
    'endDate': endDate,
    'budget': budget,
    'documents': documents,
    'employeeInWork': employeeInWork,
    'statusWork': statusWork,
    'workUbication': workUbication,
    'projectType': projectType,
  };
}

}
