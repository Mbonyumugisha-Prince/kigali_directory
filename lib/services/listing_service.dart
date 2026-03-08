import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class ListingService {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('listings');

  // Real-time stream of all listings
  Stream<List<Listing>> streamAllListings() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) =>
                Listing.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> createListing(Listing listing, String uid) async {
    await _col.add(listing.toMap(uid));
  }

  Future<void> updateListing(Listing listing) async {
    await _col.doc(listing.id).update(listing.toUpdateMap());
  }

  Future<void> deleteListing(String id) async {
    await _col.doc(id).delete();
  }
}
