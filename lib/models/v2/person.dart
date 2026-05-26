import 'package:fl_mhis_hr/models/v2/religion.dart';

class Person {
  int? id;
  String? fullname;
  String? barcode;
  String? email;
  String? address;
  String? currentAddress;
  String? birthPlace;
  String? birthDate;
  String? phone;
  String? avatar;
  String? mobilePhone;
  String? gendre;
  String? maritalStatus;
  String? bloodType;
  String? createdAt;
  String? updatedAt;
  String? firstName;
  String? lastName;
  String? identityType;
  String? identityNumber;
  String? expiredDateIdentityId;
  String? postalCode;
  String? passportNumber;
  Religion? religion;

  Person({
    this.id,
    this.fullname,
    this.barcode,
    this.email,
    this.address,
    this.currentAddress,
    this.birthPlace,
    this.birthDate,
    this.phone,
    this.avatar,
    this.mobilePhone,
    this.gendre,
    this.maritalStatus,
    this.bloodType,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.identityType,
    this.identityNumber,
    this.expiredDateIdentityId,
    this.postalCode,
    this.passportNumber,
    this.religion,
  });

  Person.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullname = json['fullname'];
    barcode = json['barcode'];
    email = json['email'];
    address = json['address'];
    currentAddress = json['current_address'];
    birthPlace = json['birth_place'];
    birthDate = json['birth_date'];
    phone = json['phone'];
    avatar = json['avatar'];
    mobilePhone = json['mobile_phone'];
    gendre = json['gendre'];
    maritalStatus = json['marital_status'];
    bloodType = json['blood_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    expiredDateIdentityId = json['expired_date_identity_id'];
    postalCode = json['postal_code'];
    passportNumber = json['passport_number'];
    religion =
        json['religion'] != null ? Religion.fromJson(json['religion']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullname'] = fullname;
    data['barcode'] = barcode;
    data['email'] = email;
    data['address'] = address;
    data['current_address'] = currentAddress;
    data['birth_place'] = birthPlace;
    data['birth_date'] = birthDate;
    data['phone'] = phone;
    data['avatar'] = avatar;
    data['mobile_phone'] = mobilePhone;
    data['gendre'] = gendre;
    data['marital_status'] = maritalStatus;
    data['blood_type'] = bloodType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['identity_type'] = identityType;
    data['identity_number'] = identityNumber;
    data['expired_date_identity_id'] = expiredDateIdentityId;
    data['postal_code'] = postalCode;
    data['passport_number'] = passportNumber;
    if (religion != null) {
      data['religion'] = religion!.toJson();
    }
    return data;
  }

  List<Map<String, dynamic>> listForm() => [
        {"title": "Fullname", "value": fullname},
        {"title": "Email", "value": email},
        {"title": "Gender", "value": gendre},
        {"title": "Place Of Birth", "value": birthPlace},
        {"title": "Birth Date", "value": birthDate},
        {"title": "Mobile Phone", "value": mobilePhone},
        {"title": "Phone", "value": phone},
        {"title": "Marital Status", "value": maritalStatus},
        {"title": "Religion", "value": religion?.name ?? ""},
        {"title": "NIK (NPWP 16 Digit)", "value": identityNumber},
        {"title": "Passport Number", "value": passportNumber},
        {"title": "Passport Expired Date", "value": expiredDateIdentityId},
        {"title": "Citizen ID Address", "value": address},
        {"title": "Residential", "value": currentAddress},
        {"title": "Blood Type", "value": bloodType}
      ];
}
