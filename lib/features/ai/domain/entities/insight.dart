/// Represents an AI-generated insight regarding the user's finances.
class Insight {
  final String title;
  final String description;
  final double impactScore;

  const Insight({
    required this.title,
    required this.description,
    required this.impactScore,
  });
}
