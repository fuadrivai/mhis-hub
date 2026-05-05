class JobPosition {
  int? id;
  String? name;
  int? level;
  String? description;
  int? parentJobId;
  int? branchId;

  JobPosition(
      {this.id,
      this.name,
      this.level,
      this.description,
      this.parentJobId,
      this.branchId});

  JobPosition.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    level = json['level'];
    description = json['description'];
    parentJobId = json['parent_job_id'];
    branchId = json['branch_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['level'] = level;
    data['description'] = description;
    data['parent_job_id'] = parentJobId;
    data['branch_id'] = branchId;
    return data;
  }
}
