# Fix Apartment Image Upload Issue

## Steps:
- [x] Step 1: Implement Supabase Storage upload in `lib/add_edit_apartment_screen.dart` _saveApartment()
  - Upload _selectedImage to bucket 'apartment-images/{managerId}/{uuid}.{ext}'
  - Get public URL
  - Save URL to DB
  - Handle new and edit cases
- [ ] Step 2: Test add new apartment with image
- [ ] Step 3: Test edit existing apartment image
- [ ] Step 4: Verify images display in dashboard and details screens
- [ ] Step 5: Mark complete and attempt_completion

Current: Updated for bucket setup.

**Supabase Setup Instructions (one-time):**
1. Go to https://supabase.com/dashboard/~>project/storage/buckets
2. Click 'Create bucket' → Name: `apartment-images` → Public bucket: ON
3. Add policy: SELECT → Target Roles: public → Using: `true`

**Then test:**
- `flutter run`, login as apartment manager, add apartment with photo → auto-creates/uploads.

Bucket not present? Supabase auto-creates on first upload, but public policy needed for Image.network to load.
