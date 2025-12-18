class BudgetModel {
  final String? id;
  final String? workId;
  final String customerId;
  final String customerName;
  final String email;
  final String projectAddress;
  final String projectType;
  final String m2;
  final String? levels;
  final String? rooms;
  final List<String> materials;
  final bool? demolition;
  final List<String> approvals;
  final String budgetDate;
  final List<String> subcontractors;
  final String startDate;
  final String endDate;
  final double estimatedBudget;
  final String currency;
  final bool? advancePayment;
  final List<String> documentation;
  final String status;

  BudgetModel({
    this.id,
    this.workId,
    required this.customerId,
    required this.customerName,
    required this.email,
    required this.projectAddress,
    required this.projectType,
    required this.m2,
    this.levels,
    this.rooms,
    required this.materials,
    this.demolition,
    required this.approvals,
    required this.budgetDate,
    required this.subcontractors,
    required this.startDate,
    required this.endDate,
    required this.estimatedBudget,
    required this.currency,
    this.advancePayment,
    required this.documentation,
    this.status = "PENDIENTE",
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['_id'],
      workId: json['workId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      email: json['email'],
      projectAddress: json['projectAddress'],
      projectType: json['projectType'],
      m2: json['m2'],
      levels: json['levels'],
      rooms: json['rooms'],
      materials: List<String>.from(json['materials'] ?? []),
      demolition: json['demolition'] ?? false,
      approvals: List<String>.from(json['approvals'] ?? []),
      budgetDate: json['budgetDate'],
      subcontractors: List<String>.from(json['subcontractors'] ?? []),
      startDate: json['startDate'],
      endDate: json['endDate'],
      estimatedBudget: json['estimatedBudget'].toDouble(),
      currency: json['currency'],
      advancePayment: json['advancePayment'] ?? false,
      documentation: List<String>.from(json['documentation'] ?? []),
      status: json['status'] ?? "DENEGADO",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workId': workId,
      'customerId': customerId,
      'customerName': customerName,
      'email': email,
      'projectAddress': projectAddress,
      'projectType': projectType,
      'm2': m2,
      'levels': levels,
      'rooms': rooms,
      'materials': materials,
      'demolition': demolition,
      'approvals': approvals,
      'budgetDate': budgetDate,
      'subcontractors': subcontractors,
      'startDate': startDate,
      'endDate': endDate,
      'estimatedBudget': estimatedBudget,
      'currency': currency,
      'advancePayment': advancePayment,
      'documentation': documentation,
      'status': status,
    };
  }
}
