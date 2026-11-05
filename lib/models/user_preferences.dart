class UserPreferences {
  final String name;
  final String age;
  final String budget;
  final String location;
  final String availableTime;
  final List<String> interests;
  final int familyMembers;
  final bool hasChildren;
  final int childrenCount;
  final String visitorType;
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
    this.childrenCount = 0,
    this.visitorType = 'egyptian',
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
    int? childrenCount,
    String? visitorType,
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
    childrenCount: childrenCount ?? this.childrenCount,
    visitorType: visitorType ?? this.visitorType,
    preferredPeriod: preferredPeriod ?? this.preferredPeriod,
  );

  Map<String, dynamic> toJson() => {
    'name': name, 'age': age, 'budget': budget, 'location': location,
    'availableTime': availableTime, 'interests': interests,
    'familyMembers': familyMembers, 'hasChildren': hasChildren,
    'childrenCount': childrenCount, 'visitorType': visitorType,
    'preferredPeriod': preferredPeriod,
  };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
    name: json['name']?.toString() ?? 'Explorer',
    age: json['age']?.toString() ?? '',
    budget: json['budget']?.toString() ?? '',
    location: json['location']?.toString() ?? '',
    availableTime: json['availableTime']?.toString() ?? '',
    interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
    familyMembers: (json['familyMembers'] as num?)?.toInt() ?? 1,
    hasChildren: json['hasChildren'] == true,
    childrenCount: (json['childrenCount'] as num?)?.toInt() ?? 0,
    visitorType: json['visitorType']?.toString() ?? 'egyptian',
    preferredPeriod: json['preferredPeriod']?.toString() ?? 'Morning',
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
