class FamilyMember {
  String name;
  String gender;
  int age;

  FamilyMember({required this.name, required this.gender, required this.age});
}

class Family {
  String headName;
  String spouseName;
  int memberCount;
  List<FamilyMember> members;
  List<String> phoneNumbers;
  String displacementPlace;
  String currentResidence;
  String homeType;
  bool hasProvider;
  List<String> needs;
  Map<String, String> fulfillment;
  String notes;

  Family({
    required this.headName,
    required this.spouseName,
    required this.memberCount,
    required this.members,
    required this.phoneNumbers,
    required this.displacementPlace,
    required this.currentResidence,
    required this.homeType,
    required this.hasProvider,
    required this.needs,
    required this.fulfillment,
    required this.notes,
  });
}