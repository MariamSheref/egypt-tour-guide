class UserPreferences {
  final String name;
  final String age;
  final String budget;
  final String location;
  final String availableTime;
  final List<String> interests;

  const UserPreferences({
    this.name = 'Explorer',
    this.age = '',
    this.budget = '',
    this.location = '',
    this.availableTime = '',
    this.interests = const [],
  });

  UserPreferences copyWith({
    String? name,
    String? age,
    String? budget,
    String? location,
    String? availableTime,
    List<String>? interests,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      age: age ?? this.age,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      availableTime: availableTime ?? this.availableTime,
      interests: interests ?? this.interests,
    );
  }

  String get interestsLabel =>
      interests.isEmpty ? 'None selected' : interests.join(', ');

  bool get isComplete =>
      budget.isNotEmpty && location.isNotEmpty && availableTime.isNotEmpty;
}
