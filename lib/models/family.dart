class Family {
  List<dynamic>? members;
  List<dynamic>? emergencyContacts;

  Family({this.members, this.emergencyContacts});

  Family.fromJson(Map<String, dynamic> json) {
    if (json['members'] != null) {
      members = <Null>[];
      json['members'].forEach((v) {
        // members!.add(Null.fromJson(v));
      });
    }
    if (json['emergency_contacts'] != null) {
      emergencyContacts = <Null>[];
      json['emergency_contacts'].forEach((v) {
        // emergencyContacts!.add(Null.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (members != null) {
      data['members'] = members!.map((v) => v.toJson()).toList();
    }
    if (emergencyContacts != null) {
      data['emergency_contacts'] =
          emergencyContacts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
