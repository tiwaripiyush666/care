abstract class ServiceProvider {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewsCount;
  final double hourlyRate;
  final String experienceYears;
  final String description;
  final List<String> categories;
  final bool isVerified;
  final Map<String, dynamic> metadata;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewsCount,
    required this.hourlyRate,
    required this.experienceYears,
    required this.description,
    required this.categories,
    required this.isVerified,
    this.metadata = const {},
  });
}

class ElderCareProvider extends ServiceProvider {
  final List<String> medicalSpecializations;
  final bool hasNursingDegree;
  final List<String> supportedAilments; // e.g., Dementia, Parkinsons

  const ElderCareProvider({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewsCount,
    required super.hourlyRate,
    required super.experienceYears,
    required super.description,
    required super.categories,
    required super.isVerified,
    required this.medicalSpecializations,
    required this.hasNursingDegree,
    required this.supportedAilments,
    super.metadata,
  });
}

class ChildCareProvider extends ServiceProvider {
  final bool hasFirstAidCertification;
  final List<String> ageGroupsTended; // e.g., Infant, Toddler
  final List<String> educationalActivities;

  const ChildCareProvider({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewsCount,
    required super.hourlyRate,
    required super.experienceYears,
    required super.description,
    required super.categories,
    required super.isVerified,
    required this.hasFirstAidCertification,
    required this.ageGroupsTended,
    required this.educationalActivities,
    super.metadata,
  });
}

class HandymanProvider extends ServiceProvider {
  final List<String> toolsOwned;
  final List<String> specializedServices; // e.g., Plumbing, Electrical
  final bool isLicensedContractor;

  const HandymanProvider({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewsCount,
    required super.hourlyRate,
    required super.experienceYears,
    required super.description,
    required super.categories,
    required super.isVerified,
    required this.toolsOwned,
    required this.specializedServices,
    required this.isLicensedContractor,
    super.metadata,
  });
}
