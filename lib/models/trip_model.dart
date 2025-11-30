// Trip model for 'trips' table
class Trip {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final int? seats;
  final String? image;
  final DateTime? createdAt;

  Trip({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.price,
    required this.startDate,
    required this.endDate,
    this.seats,
    this.image,
    this.createdAt,
  });

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'].toString(),
      title: map['title'] as String,
      description: map['description'] as String?,
      location: map['location'] as String?,
      price: (map['price'] as num).toDouble(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      seats: map['seats'] as int?,
      image: map['image'] as String?,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'price': price,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'seats': seats,
      'image': image,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
