// Depending on each age group, a different level of detial will be generated for coloring pictures

enum AgeGroup {
  toddler, // 3-4 years
  kid, // 5-7 years
  teen, // 8-10 years
}

extension AgeGroupLabel on AgeGroup {
  // The label shown on the age-selector buttons in the UI.
  String get label {
    switch (this) {
      case AgeGroup.toddler:
        return '3-4';
      case AgeGroup.kid:
        return '5-7';
      case AgeGroup.teen:
        return '8-10';
    }
  }
}
