class Organization {
  int? id;
  String? name;
  int? parentOrganizationId;
  int? branchId;

  Organization({this.id, this.name, this.parentOrganizationId, this.branchId});

  Organization.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    parentOrganizationId = json['parent_organization_id'];
    branchId = json['branch_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['parent_organization_id'] = parentOrganizationId;
    data['branch_id'] = branchId;
    return data;
  }
}
