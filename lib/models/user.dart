import 'package:fl_mhis_hr/models/model.dart';

class AcademyUser {
  int? id;
  String? fullName;
  String? roleName;
  int? organId;
  String? mobile;
  String? email;
  String? bio;
  int? loggedCount;
  int? verified;
  int? financialApproval;
  int? installmentApproval;
  int? enableInstallments;
  int? disableCashback;
  int? enableRegistrationBonus;
  double? registrationBonusAmount;
  String? avatar;
  String? avatarSettings;
  String? coverImg;
  String? headline;
  String? about;
  String? address;
  int? countryId;
  int? provinceId;
  int? cityId;
  int? districtId;
  Branch? location;
  int? levelOfTraining;
  String? meetingType;
  String? status;
  int? accessContent;
  String? language;
  String? currency;
  String? timezone;
  int? newsletter;
  int? publicMessage;
  String? identityScan;
  String? certificate;
  String? commission;
  int? affiliate;
  int? canCreateStore;
  int? ban;
  String? banStartAt;
  String? banEndAt;
  int? offline;
  String? offlineMessage;
  int? createdAt;
  int? updatedAt;
  String? deletedAt;
  int? categoryId;
  int? locationId;
  Category? category;

  AcademyUser(
      {this.id,
      this.fullName,
      this.roleName,
      this.organId,
      this.mobile,
      this.email,
      this.bio,
      this.loggedCount,
      this.verified,
      this.financialApproval,
      this.installmentApproval,
      this.enableInstallments,
      this.disableCashback,
      this.enableRegistrationBonus,
      this.registrationBonusAmount,
      this.avatar,
      this.avatarSettings,
      this.coverImg,
      this.headline,
      this.about,
      this.address,
      this.countryId,
      this.provinceId,
      this.cityId,
      this.districtId,
      this.location,
      this.levelOfTraining,
      this.meetingType,
      this.status,
      this.accessContent,
      this.language,
      this.currency,
      this.timezone,
      this.newsletter,
      this.publicMessage,
      this.identityScan,
      this.certificate,
      this.commission,
      this.affiliate,
      this.canCreateStore,
      this.ban,
      this.banStartAt,
      this.banEndAt,
      this.offline,
      this.offlineMessage,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.categoryId,
      this.locationId,
      this.category});

  AcademyUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    roleName = json['role_name'];
    organId = json['organ_id'];
    mobile = json['mobile'];
    email = json['email'];
    bio = json['bio'];
    loggedCount = json['logged_count'];
    verified = json['verified'];
    financialApproval = json['financial_approval'];
    installmentApproval = json['installment_approval'];
    enableInstallments = json['enable_installments'];
    disableCashback = json['disable_cashback'];
    enableRegistrationBonus = json['enable_registration_bonus'];
    registrationBonusAmount = json['registration_bonus_amount'];
    avatar = json['avatar'];
    avatarSettings = json['avatar_settings'];
    coverImg = json['cover_img'];
    headline = json['headline'];
    about = json['about'];
    address = json['address'];
    countryId = json['country_id'];
    provinceId = json['province_id'];
    cityId = json['city_id'];
    districtId = json['district_id'];
    location =
        json['location'] != null ? Branch.fromJson(json['location']) : null;
    levelOfTraining = json['level_of_training'];
    meetingType = json['meeting_type'];
    status = json['status'];
    accessContent = json['access_content'];
    language = json['language'];
    currency = json['currency'];
    timezone = json['timezone'];
    newsletter = json['newsletter'];
    publicMessage = json['public_message'];
    identityScan = json['identity_scan'];
    certificate = json['certificate'];
    commission = json['commission'];
    affiliate = json['affiliate'];
    canCreateStore = json['can_create_store'];
    ban = json['ban'];
    banStartAt = json['ban_start_at'];
    banEndAt = json['ban_end_at'];
    offline = json['offline'];
    offlineMessage = json['offline_message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    categoryId = json['category_id'];
    locationId = json['location_id'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['full_name'] = fullName;
    data['role_name'] = roleName;
    data['organ_id'] = organId;
    data['mobile'] = mobile;
    data['email'] = email;
    data['bio'] = bio;
    data['logged_count'] = loggedCount;
    data['verified'] = verified;
    data['financial_approval'] = financialApproval;
    data['installment_approval'] = installmentApproval;
    data['enable_installments'] = enableInstallments;
    data['disable_cashback'] = disableCashback;
    data['enable_registration_bonus'] = enableRegistrationBonus;
    data['registration_bonus_amount'] = registrationBonusAmount;
    data['avatar'] = avatar;
    data['avatar_settings'] = avatarSettings;
    data['cover_img'] = coverImg;
    data['headline'] = headline;
    data['about'] = about;
    data['address'] = address;
    data['country_id'] = countryId;
    data['province_id'] = provinceId;
    data['city_id'] = cityId;
    data['district_id'] = districtId;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['level_of_training'] = levelOfTraining;
    data['meeting_type'] = meetingType;
    data['status'] = status;
    data['access_content'] = accessContent;
    data['language'] = language;
    data['currency'] = currency;
    data['timezone'] = timezone;
    data['newsletter'] = newsletter;
    data['public_message'] = publicMessage;
    data['identity_scan'] = identityScan;
    data['certificate'] = certificate;
    data['commission'] = commission;
    data['affiliate'] = affiliate;
    data['can_create_store'] = canCreateStore;
    data['ban'] = ban;
    data['ban_start_at'] = banStartAt;
    data['ban_end_at'] = banEndAt;
    data['offline'] = offline;
    data['offline_message'] = offlineMessage;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['category_id'] = categoryId;
    data['location_id'] = locationId;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}
