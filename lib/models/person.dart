class Person {
  String? firstName;
  String? lastName;
  String? fullName;
  String? barcode;
  String? email;
  String? identityType;
  String? identityNumber;
  String? nik;
  String? passport;
  String? expiredDateIdentityId;
  String? postalCode;
  String? address;
  String? currentAddress;
  String? birthPlace;
  String? birthDate;
  String? phone;
  String? mobilePhone;
  String? gender;
  String? maritalStatus;
  String? bloodType;
  String? religion;
  String? avatar;

  Person({
    this.firstName,
    this.lastName,
    this.barcode,
    this.fullName,
    this.email,
    this.identityType,
    this.identityNumber,
    this.nik,
    this.passport,
    this.expiredDateIdentityId,
    this.postalCode,
    this.address,
    this.currentAddress,
    this.birthPlace,
    this.birthDate,
    this.phone,
    this.mobilePhone,
    this.gender,
    this.maritalStatus,
    this.bloodType,
    this.religion,
    this.avatar,
  });

  Person.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    fullName = "$firstName $lastName";
    barcode = json['barcode'];
    email = json['email'];
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    nik = json['nik'];
    passport = json['passport'];
    expiredDateIdentityId = json['expired_date_identity_id'];
    postalCode = json['postal_code'];
    address = json['address'];
    currentAddress = json['current_address'];
    birthPlace = json['birth_place'];
    birthDate = json['birth_date'];
    phone = json['phone'];
    mobilePhone = json['mobile_phone'];
    gender = json['gender'];
    maritalStatus = json['marital_status'];
    bloodType = json['blood_type'];
    religion = json['religion'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['barcode'] = barcode;
    data['email'] = email;
    data['identity_type'] = identityType;
    data['identity_number'] = identityNumber;
    data['nik'] = nik;
    data['passport'] = passport;
    data['expired_date_identity_id'] = expiredDateIdentityId;
    data['postal_code'] = postalCode;
    data['address'] = address;
    data['current_address'] = currentAddress;
    data['birth_place'] = birthPlace;
    data['birth_date'] = birthDate;
    data['phone'] = phone;
    data['mobile_phone'] = mobilePhone;
    data['gender'] = gender;
    data['marital_status'] = maritalStatus;
    data['blood_type'] = bloodType;
    data['religion'] = religion;
    data['avatar'] = avatar;
    return data;
  }

  List<Map<String, dynamic>> listForm() => [
        {"title": "Fullname", "value": fullName},
        {"title": "Email", "value": email},
        {"title": "Gender", "value": gender},
        {"title": "Gender", "value": gender},
        {"title": "Place Of Birth", "value": birthPlace},
        {"title": "Birth Date", "value": birthDate},
        {"title": "Mobile Phone", "value": mobilePhone},
        {"title": "Phone", "value": phone},
        {"title": "Marital Status", "value": maritalStatus},
        {"title": "Religion", "value": religion},
        {"title": "NIK (NPWP 16 Digit)", "value": nik},
        {"title": "Passport Number", "value": passport},
        {"title": "Passport Expired Date", "value": expiredDateIdentityId},
        {"title": "Citizen ID Address", "value": address},
        {"title": "Residential", "value": currentAddress},
        {"title": "Blood Type", "value": bloodType}
      ];
}
