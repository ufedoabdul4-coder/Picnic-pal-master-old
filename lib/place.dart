class Place {
  final String name;
  final double rating;
  final int totalRatings;
  final String? photoUrl;
  final String placeId;
  final String description;
  final double latitude;
  final double longitude;

  Place({
    required this.name,
    required this.rating,
    required this.totalRatings,
    required this.placeId,
    this.photoUrl,
    this.description = '',
    required this.latitude,
    required this.longitude,
  });
}