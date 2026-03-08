import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/listing_service.dart';

class ListingProvider extends ChangeNotifier {
  final ListingService _service = ListingService();

  StreamSubscription<List<Listing>>? _sub;
  List<Listing> _all      = [];
  bool          _loading  = false;
  String?       _error;
  String        _search   = '';
  String        _category = 'All';

  bool    get isLoading        => _loading;
  String? get error            => _error;
  String  get search           => _search;
  String  get selectedCategory => _category;
  List<Listing> get all        => _all;

  List<Listing> get filteredListings {
    return _all.where((l) {
      final q = _search.toLowerCase();
      final matchesSearch = _search.isEmpty ||
          l.name.toLowerCase().contains(q) ||
          l.address.toLowerCase().contains(q) ||
          l.category.toLowerCase().contains(q);
      final matchesCategory =
          _category == 'All' || l.category == _category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Listing> userListings(String uid) =>
      _all.where((l) => l.createdBy == uid).toList();

  // Returns the up-to-date listing for [id], or null if not found.
  Listing? findById(String id) =>
      _all.cast<Listing?>().firstWhere((l) => l?.id == id, orElse: () => null);

  void initStreams() {
    // Only skip if the subscription is already active (no error).
    if (_sub != null) return;
    _loading = true;
    _error   = null;
    notifyListeners();
    _sub = _service.streamAllListings().listen(
      (listings) {
        _all     = listings;
        _loading = false;
        _error   = null;
        notifyListeners();
      },
      onError: (e) {
        _error   = e.toString();
        _loading = false;
        _sub     = null; // Allow retry via initStreams()
        notifyListeners();
      },
    );
  }

  void refresh() {
    _sub?.cancel();
    _sub = null;
    initStreams();
  }

  void setSearch(String query) {
    _search = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  Future<bool> createListing(Listing listing, String uid) async {
    try {
      await _service.createListing(listing, uid);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    // Optimistic update: replace the listing locally right away so the UI
    // refreshes instantly without waiting for the Firestore stream round-trip.
    final idx = _all.indexWhere((l) => l.id == listing.id);
    List<Listing>? previous;
    if (idx != -1) {
      previous = List<Listing>.from(_all);
      _all     = List<Listing>.from(_all)..[idx] = listing;
      notifyListeners();
    }
    try {
      await _service.updateListing(listing);
      return true;
    } catch (e) {
      // Roll back the optimistic update on failure.
      if (previous != null) {
        _all = previous;
      }
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
