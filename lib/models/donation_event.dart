// lib/models/donation_event.dart
class DonationEvent {
  final String id;
  final String title;
  final String date; // Formato esperado: "YYYY-MM-DD" (ex: "2025-12-25")
  final String location;
  final List<String> availableTimes;

  const DonationEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.availableTimes,
  });

  // Fábrica para converter os dados vindos do Firebase
  factory DonationEvent.fromMap(String id, Map<dynamic, dynamic> map) {
    return DonationEvent(
      id: id,
      title: map['titulo']?.toString() ?? 'Sem Título',
      // Se não tiver data, coloca uma antiga para o filtro esconder
      date: map['data']?.toString() ?? '1900-01-01',
      location: map['local']?.toString() ?? 'Local não informado',
      // Garante que a lista de horários seja uma List<String>
      availableTimes: (map['horarios'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}