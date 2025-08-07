class CustomerModel {
  final String? id; // _id del cliente en MongoDB
  final String? userId; // Usuario que registró el cliente
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
  final List<String> worksActive; // Lista de IDs de trabajos activos
  final List<String> documents;
  final DateTime createdAt;
  final bool active;

  CustomerModel({
    this.id,
    this.userId,
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
    required this.worksActive,
    required this.documents,
    required this.createdAt,
    required this.active,
  });

  /// **Método para convertir JSON a `CustomerModel`**
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Función auxiliar para convertir cualquier tipo a String de forma segura
    String safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      return value is String ? value : value.toString();
    }
    
    // Función auxiliar para convertir cualquier tipo a bool de forma segura
    bool safeBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      if (value is num) return value != 0;
      return defaultValue;
    }
    
    // Función auxiliar para parsear DateTime de forma segura
    DateTime safeDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    // Función auxiliar para convertir a List<String> de forma segura
    List<String> safeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((item) => item?.toString() ?? '').toList();
      }
      if (value is Map) {
        return value.values.map((item) => item?.toString() ?? '').toList();
      }
      return [];
    }
    
    return CustomerModel(
      id: safeString(json['_id'], ''),
      userId: safeString(json['userId'], ''),
      name: safeString(json['name'], 'No Name'),
      secondName: safeString(json['secondName'], ''),
      dni: safeString(json['dni'], ''),
      cuit: safeString(json['cuit'], ''),
      cuil: safeString(json['cuil'], ''),
      address: safeString(json['address'], ''),
      workDirection: safeString(json['workDirection'], ''),
      contactNumber: safeString(json['contactNumber'], 'No Contact'),
      email: safeString(json['email'], 'No Email'),
      password: safeString(json['password'], ''),
      firstRegister: safeBool(json['firstRegister'], true),
      clienteActivo: safeBool(json['clienteActivo'], true),
      worksActive: safeStringList(json['worksActive']),
      documents: safeStringList(json['documents']),
      createdAt: safeDateTime(json['createdAt']),
      active: safeBool(json['active'], true),
    );
  }

  /// **Método para convertir `CustomerModel` a JSON**
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Asegura que se envíe al backend
      'userId': userId,
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
      'worksActive': worksActive, // Lista de trabajos activos
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'active': active,
    };
  }
}
