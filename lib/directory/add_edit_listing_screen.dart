import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/listing_provider.dart';
import '../../providers/auth_providers.dart';
import '../../utils/app_theme.dart';

class AddEditListingScreen extends StatefulWidget {
  final Listing? listing;
  const AddEditListingScreen({super.key, this.listing});

  @override
  State<AddEditListingScreen> createState() => _AddEditListingScreenState();
}

class _AddEditListingScreenState extends State<AddEditListingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _descCtrl;

  String _category  = kCategories.first;
  bool   _saving    = false;

  bool get _isEdit => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameCtrl    = TextEditingController(text: l?.name          ?? '');
    _addressCtrl = TextEditingController(text: l?.address       ?? '');
    _contactCtrl = TextEditingController(text: l?.contactNumber ?? '');
    _descCtrl    = TextEditingController(text: l?.description   ?? '');
    if (l != null) _category = l.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<ListingProvider>();
    final uid      = context.read<AuthProvider>().user?.uid ?? '';

    final listing = Listing(
      id:            widget.listing?.id ?? '',
      name:          _nameCtrl.text.trim(),
      category:      _category,
      address:       _addressCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      description:   _descCtrl.text.trim(),
      latitude:      widget.listing?.latitude  ?? 0.0,
      longitude:     widget.listing?.longitude ?? 0.0,
      createdBy:     widget.listing?.createdBy ?? uid,
      createdAt:     widget.listing?.createdAt ?? DateTime.now(),
    );

    final ok = _isEdit
        ? await provider.updateListing(listing)
        : await provider.createListing(listing, uid);

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.error ?? 'Failed to save. Try again.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Listing' : 'Add Listing',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Place Name
            _label('Place / Service Name'),
            _field(
              controller: _nameCtrl,
              hint: 'e.g. King Faisal Hospital',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),

            const SizedBox(height: 18),

            // Category
            _label('Category'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  dropdownColor: AppColors.navy,
                  isExpanded: true,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: kCategories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Row(children: [
                              Icon(categoryIconData(c),
                                  color: AppColors.accent, size: 18),
                              const SizedBox(width: 10),
                              Text(c),
                            ]),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _category = v ?? _category),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Address
            _label('Address'),
            _field(
              controller: _addressCtrl,
              hint: 'e.g. KG 7 Ave, Kigali',
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Address is required' : null,
            ),

            const SizedBox(height: 18),

            // Contact
            _label('Contact Number'),
            _field(
              controller: _contactCtrl,
              hint: 'e.g. +250 788 000 000',
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Contact number is required'
                  : null,
            ),

            const SizedBox(height: 18),

            // Description
            _label('Description'),
            _field(
              controller: _descCtrl,
              hint: 'Describe this place or service…',
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),

            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.darkNavy,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.darkNavy),
                    )
                  : Text(_isEdit ? 'Save Changes' : 'Add Listing'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            )),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(hintText: hint),
        validator: validator,
      );
}

IconData categoryIconData(String category) {
  switch (category) {
    case 'Hospital':           return Icons.local_hospital_rounded;
    case 'Police Station':     return Icons.local_police_rounded;
    case 'Library':            return Icons.local_library_rounded;
    case 'Restaurant':         return Icons.restaurant_rounded;
    case 'Café':               return Icons.coffee_rounded;
    case 'Park':               return Icons.park_rounded;
    case 'Tourist Attraction': return Icons.camera_alt_rounded;
    default:                   return Icons.place_rounded;
  }
}
