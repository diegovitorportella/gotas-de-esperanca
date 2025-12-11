class DonationEvent {
  final String title;
  final String date;
  final String location;
  final List<String> availableTimes;

  // Adicione a palavra-chave "const" aqui
  const DonationEvent({
    required this.title,
    required this.date,
    required this.location,
    required this.availableTimes,
  });
}