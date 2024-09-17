class PayrollInfo {
  String? ptkpStatus;
  int? costCenterId;
  String? costCenterName;
  int? costCenterCategoryId;
  String? costCenterCategoryName;

  PayrollInfo({
    this.ptkpStatus,
    this.costCenterId,
    this.costCenterName,
    this.costCenterCategoryId,
    this.costCenterCategoryName,
  });

  PayrollInfo.fromJson(Map<String, dynamic> json) {
    ptkpStatus = json['ptkp_status'];
    costCenterId = json['cost_center_id'];
    costCenterName = json['cost_center_name'];
    costCenterCategoryId = json['cost_center_category_id'];
    costCenterCategoryName = json['cost_center_category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ptkp_status'] = ptkpStatus;
    data['cost_center_id'] = costCenterId;
    data['cost_center_name'] = costCenterName;
    data['cost_center_category_id'] = costCenterCategoryId;
    data['cost_center_category_name'] = costCenterCategoryName;
    return data;
  }
}
