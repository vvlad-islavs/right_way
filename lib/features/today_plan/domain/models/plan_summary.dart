class PlanSummary {
  const PlanSummary({
    required this.id,
    required this.name,
    required this.createdAtMs,
    required this.isActive,
  });

  final int id;
  final String name;
  final int createdAtMs;
  final bool isActive;
}
