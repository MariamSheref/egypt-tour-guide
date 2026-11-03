class UserPreferences {
  final String name;
  final String age;
  final String budget;
  final String location;
  final String availableTime;
  final List<String> interests;
  final int familyMembers;
  final bool hasChildren;
  final String preferredPeriod;

  const UserPreferences({
    this.name = 'Explorer',
    this.age = '',
    this.budget = '',
    this.location = '',
    this.availableTime = '',
    this.interests = const [],
    this.familyMembers = 1,
    this.hasChildren = false,
    this.preferredPeriod = 'Any time',
  });

  UserPreferences copyWith({
    String? name,
    String? age,
    String? budget,
    String? location,
    String? availableTime,
    List<String>? interests,
    int? familyMembers,
    bool? hasChildren,
    String? preferredPeriod,
  }) => UserPreferences(
    name: name ?? this.name,
    age: age ?? this.age,
    budget: budget ?? this.budget,
    location: location ?? this.location,
    availableTime: availableTime ?? this.availableTime,
    interests: interests ?? this.interests,
    familyMembers: familyMembers ?? this.familyMembers,
    hasChildren: hasChildren ?? this.hasChildren,
    preferredPeriod: preferredPeriod ?? this.preferredPeriod,
  );

  String get interestsLabel =>
      interests.isEmpty ? 'None selected' : interests.join(', ');

  double? get budgetEgp => double.tryParse(budget);

  bool get isComplete => budgetEgp != null && budgetEgp! > 0 &&
      location.isNotEmpty && availableTime.isNotEmpty && familyMembers > 0;

  /// Future POST /recommend request payload. Location is currently city-level.
  Map<String, dynamic> toRecommendationRequest() => {
    'city': location,
    'budget': budgetEgp,
    'family_members': familyMembers,
    'has_children': hasChildren,
    'available_time': availableTime,
    'preferred_period': preferredPeriod,
    'interests': interests,
  };
}
