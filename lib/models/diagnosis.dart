enum DiagnosisLevel {
  healthy,
  warning,
  critical,
}

class Diagnosis {
  final DiagnosisLevel level;
  final String title;
  final String message;
  final List<String> recommendations;

  const Diagnosis({
    required this.level,
    required this.title,
    required this.message,
    required this.recommendations,
  });
}