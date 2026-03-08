import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';
import '../directory/directory_screen.dart';
import '../directory/listing_detail_screen.dart';
import '../directory/add_edit_listing_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid      = context.watch<AuthProvider>().user?.uid ?? '';
    final provider = context.watch<ListingProvider>();
    final listings = provider.userListings(uid);

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MY LISTINGS',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Places',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${listings.length} listing${listings.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Content
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent))
                  : listings.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: listings.length,
                          itemBuilder: (ctx, i) => _MyListingCard(
                            listing: listings[i],
                            onTap: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                    listing: listings[i]),
                              ),
                            ),
                            onEdit: () => Navigator.push(
                              ctx,
                              MaterialPageRoute(
                                builder: (_) => AddEditListingScreen(
                                    listing: listings[i]),
                              ),
                            ),
                            onDelete: () =>
                                _confirmDelete(ctx, listings[i], provider),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_my_listings',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddEditListingScreen()),
        ),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: AppColors.darkNavy),
      ),
    );
  }

  Widget _emptyState(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border_rounded,
                size: 64, color: AppColors.navyBorder),
            const SizedBox(height: 16),
            const Text(
              "No listings yet",
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your first place to the directory!',
              style:
                  TextStyle(color: AppColors.textHint, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditListingScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Listing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.darkNavy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );

  Future<void> _confirmDelete(
      BuildContext context, Listing listing, ListingProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.navy,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Listing',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${listing.name}"? This cannot be undone.',
          style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteListing(listing.id);
    }
  }
}

class _MyListingCard extends StatelessWidget {
  final Listing      listing;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyListingCard({
    required this.listing,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navyBorder),
      ),
      child: Column(
        children: [
          ListingCard(
            listing: listing,
            onTap: onTap,
            trailing: const SizedBox.shrink(),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.navyBorder,
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded,
                      size: 16, color: AppColors.accent),
                  label: const Text('Edit',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.navyBorder),
              Expanded(
                child: TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: AppColors.error),
                  label: const Text('Delete',
                      style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
