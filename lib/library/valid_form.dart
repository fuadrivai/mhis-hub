class ValidForm {
  static String? dropDownEmpty(String? value) {
    if (value == null) {
      return "Field cannot be empty";
    }
    return null;
  }

  static String? emptyValue(String? value) {
    if (value!.isEmpty) {
      return "Field cannot be empty";
    }
    return null;
  }

  static String? matchValue(String? value, String? data, String title) {
    if (value!.isEmpty) {
      return "Field cannot be empty";
    } else {
      if (value != data) {
        return title;
      }
    }
    return null;
  }

  static String? greaterThan(String? value, String? data, String title) {
    double val = double.parse((value =
            (value == "" || value == null) ? "0" : value)
        .replaceAll(",", ""));
    double vals = double.parse(data ?? "0");
    if (val <= vals) {
      return "harus lebih besar dari $title";
    }
    return null;
  }
}
