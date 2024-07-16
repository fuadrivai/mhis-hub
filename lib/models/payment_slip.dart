class PaymentSlip {
  String? periode;
  String? link;

  PaymentSlip({this.periode, this.link});

  PaymentSlip.fromJson(Map<String, dynamic> json) {
    periode = json['periode'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['periode'] = periode;
    data['link'] = link;
    return data;
  }
}
