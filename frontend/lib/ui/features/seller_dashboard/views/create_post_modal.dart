import 'package:flutter/material.dart';
import 'package:artisan_market/core/theme/app_theme.dart';
import 'package:artisan_market/ui/features/seller_dashboard/view_models/seller_view_model.dart';

class CreatePostModal extends StatefulWidget {
  final SellerViewModel sellerViewModel;

  const CreatePostModal({super.key, required this.sellerViewModel});

  static void show(BuildContext context, SellerViewModel sellerViewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => CreatePostModal(sellerViewModel: sellerViewModel),
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController(text: 'Hand-carved Rosewood Jewellery Box');
  final _priceController = TextEditingController(text: '1850');
  final _stockController = TextEditingController(text: '3');
  final _descController = TextEditingController(
    text: 'Intricate brass-inlaid Sheesham wooden jewellery chest crafted by master woodturners.',
  );
  final _storyController = TextEditingController(
    text: 'Carved over 18 hours using reclaimed seasoned rosewood with floral filigree inlay work.',
  );
  final _mediaUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=800&auto=format&fit=crop&q=80',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _storyController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final stock = int.tryParse(_stockController.text) ?? 1;

    final success = await widget.sellerViewModel.createPost(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      craftStory: _storyController.text.trim(),
      mediaUrl: _mediaUrlController.text.trim(),
      price: price,
      stockQuantity: stock,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.forestGreen,
          content: Text('🎉 Craft post published to Discovery Feed!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Upload New Craft Piece',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Product Title',
                    hintText: 'e.g. Madhubani Peacock Canvas',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (₹)',
                          prefixText: '₹ ',
                        ),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Inventory Stock',
                          hintText: 'e.g. 5',
                        ),
                        validator: (v) => v == null || int.tryParse(v) == null ? 'Enter valid stock' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe materials, dimensions, and utility',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Description required' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _storyController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Heritage Craft Story',
                    hintText: 'Tell buyers how this piece was crafted and its cultural origins',
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _mediaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Photo / Video URL',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Media URL is required' : null,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.sellerViewModel.isSaving ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: widget.sellerViewModel.isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Publish Piece to Feed',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
