import 'package:cloud_firestore/cloud_firestore.dart';

const List<String> kCategories = [
  'Hospital',
  'Police Station',
  'Library',
  'Restaurant',
  'Café',
  'Park',
  'Tourist Attraction',
];

class Listing {
  final String   id;
  final String   name;
  final String   category;
  final String   address;
  final String   contactNumber;
  final String   description;
  final double   latitude;
  final double   longitude;
  final String   createdBy;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    this.latitude  = 0.0,
    this.longitude = 0.0,
    required this.createdBy,
    required this.createdAt,
  });

  bool get hasCoordinates => latitude != 0.0 || longitude != 0.0;

  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    return Listing(
      id:            id,
      name:          map['name']          as String? ?? '',
      category:      map['category']      as String? ?? '',
      address:       map['address']       as String? ?? '',
      contactNumber: map['contactNumber'] as String? ?? '',
      description:   map['description']  as String? ?? '',
      latitude:      (map['latitude']     as num?)?.toDouble() ?? 0.0,
      longitude:     (map['longitude']    as num?)?.toDouble() ?? 0.0,
      createdBy:     map['createdBy']     as String? ?? '',
      createdAt:     (map['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap(String uid) => {
    'name':          name,
    'category':      category,
    'address':       address,
    'contactNumber': contactNumber,
    'description':   description,
    'latitude':      latitude,
    'longitude':     longitude,
    'createdBy':     uid,
    'createdAt':     FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> toUpdateMap() => {
    'name':          name,
    'category':      category,
    'address':       address,
    'contactNumber': contactNumber,
    'description':   description,
    'latitude':      latitude,
    'longitude':     longitude,
  };

  Listing copyWith({
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
  }) =>
      Listing(
        id:            id,
        name:          name          ?? this.name,
        category:      category      ?? this.category,
        address:       address       ?? this.address,
        contactNumber: contactNumber ?? this.contactNumber,
        description:   description   ?? this.description,
        latitude:      latitude      ?? this.latitude,
        longitude:     longitude     ?? this.longitude,
        createdBy:     createdBy,
        createdAt:     createdAt,
      );
}
