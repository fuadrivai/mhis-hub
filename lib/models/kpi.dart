class Kpi {
  int? nIK;
  String? name;
  String? position;
  String? email;
  int? sKL;
  int? iMTAQ;
  int? iSI;
  int? pROCESS;
  int? sPTK;
  int? pENILAIAN;
  int? tAL;
  int? teachersPerformance;
  int? kPIScoreAutomate;

  Kpi(
      {this.nIK,
      this.name,
      this.position,
      this.email,
      this.sKL,
      this.iMTAQ,
      this.iSI,
      this.pROCESS,
      this.sPTK,
      this.pENILAIAN,
      this.tAL,
      this.teachersPerformance,
      this.kPIScoreAutomate});

  Kpi.fromJson(Map<String, dynamic> json) {
    nIK = json['NIK'];
    name = json['Name'];
    position = json['Position'];
    email = json['Email'];
    sKL = json['SKL'];
    iMTAQ = json['IMTAQ'];
    iSI = json['ISI'];
    pROCESS = json['PROCESS'];
    sPTK = json['SPTK'];
    pENILAIAN = json['PENILAIAN'];
    tAL = json['TAL'];
    teachersPerformance = json['Teachers Performance'];
    kPIScoreAutomate = json['KPI Score (Automate)'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NIK'] = nIK;
    data['Name'] = name;
    data['Position'] = position;
    data['Email'] = email;
    data['SKL'] = sKL;
    data['IMTAQ'] = iMTAQ;
    data['ISI'] = iSI;
    data['PROCESS'] = pROCESS;
    data['SPTK'] = sPTK;
    data['PENILAIAN'] = pENILAIAN;
    data['TAL'] = tAL;
    data['Teachers Performance'] = teachersPerformance;
    data['KPI Score (Automate)'] = kPIScoreAutomate;
    return data;
  }
}
