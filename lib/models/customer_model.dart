class CustomerModel {
  final String? id;
  final String name;
  final String secondName;
  final String dni;
  final String cuit;
  final String cuil;
  final String address;
  final String workDirection;
  final String contactNumber;
  final String email;
  final String password;
  final bool firstRegister;
  final bool clienteActivo;
  final List<String>? worksActive; // Trabajos activos
  final List<String> documents;
  final DateTime createdAt;
  final bool active;

  CustomerModel({
    this.id,
    required this.name,
    required this.secondName,
    required this.dni,
    required this.cuit,
    required this.cuil,
    required this.address,
    required this.workDirection,
    required this.contactNumber,
    required this.email,
    required this.password,
    required this.firstRegister,
    required this.clienteActivo,
    this.worksActive,
    required this.documents,
    required this.createdAt,
    required this.active,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'],
      name: json['name'] ?? 'No Name',
      secondName: json['secondName'] ?? '',
      dni: json['dni'] ?? '',
      cuit: json['cuit'] ?? '',
      cuil: json['cuil'] ?? '',
      address: json['address'] ?? '',
      workDirection: json['workDirection'] ?? '',
      contactNumber: json['contactNumber'] ?? 'No Contact',
      email: json['email'] ?? 'No Email',
      password: json['password'] ?? '',
      firstRegister: json['firstRegister'] ?? true,
      clienteActivo: json['clienteActivo'] ?? true,
      worksActive: json.containsKey('worksActive') && json['worksActive'] != null
          ? List<String>.from(json['worksActive'])
          : null,
      documents: List<String>.from(json['documents'] ?? []),
      createdAt: json.containsKey('createdAt') && json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'secondName': secondName,
      'dni': dni,
      'cuit': cuit,
      'cuil': cuil,
      'address': address,
      'workDirection': workDirection,
      'contactNumber': contactNumber,
      'email': email,
      'password': password,
      'firstRegister': firstRegister,
      'clienteActivo': clienteActivo,
      'worksActive': worksActive ?? [],
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'active': active,
    };
  }
}
