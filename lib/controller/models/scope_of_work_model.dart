class ScopeOfWorkModel {
  String? designAndEngineering;
  String? a3SScope;
  String? clientScope;

  ScopeOfWorkModel({
    this.designAndEngineering,
    this.a3SScope,
    this.clientScope,
  });

  factory ScopeOfWorkModel.fromJson(Map<String, dynamic> json) {
    return ScopeOfWorkModel(
      designAndEngineering: json['designAndEngineering']?.toString() ?? '',
      a3SScope: json['a3SScope']?.toString() ?? '',
      clientScope: json['clientScope']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'designAndEngineering': designAndEngineering,
      'a3SScope': a3SScope,
      'clientScope': clientScope,
    };
  }
}
