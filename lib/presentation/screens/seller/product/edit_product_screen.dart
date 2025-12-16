import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();

  String _selectedCategory = "";
  String _selectedCondition = "Baru";
  String _photoUrl = "";
  File? _newImageFile;

  bool _loading = true;
  bool _saving = false;

  final List<String> _categories = [
    'Oli & Pelumas',
    'Suku Cadang Mesin',
    'Ban & Velg',
    'Aki & Battery',
    'Lampu',
    'Body Parts',
    'Aksesoris',
    'Lainnya',
  ];

  final List<String> _conditions = ['Baru', 'Bekas'];

  Future<void> _loadProduct() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);

    final product = provider.products.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => throw Exception("Product not found"),
    );

    _nameCtrl.text = product.name;
    _descCtrl.text = product.description;
    _priceCtrl.text = product.price.toString();
    _stockCtrl.text = product.stock.toString();
    _brandCtrl.text = product.brand ?? "";
    _selectedCategory = product.category;
    _selectedCondition = product.condition;
    _photoUrl = product.photoUrl;

    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _brandCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (img != null) {
      setState(() => _newImageFile = File(img.path));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);

    final old = provider.products.firstWhere((p) => p.id == widget.productId);

    final updatedProduct = ProductModel(
      id: widget.productId,
      sellerId: old.sellerId,
      bengkelId: old.bengkelId,
      name: _nameCtrl.text,
      description: _descCtrl.text,
      category: _selectedCategory,
      price: double.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      photoUrl: _photoUrl,
      brand: _brandCtrl.text.isNotEmpty ? _brandCtrl.text : null,
      condition: _selectedCondition,
      status: "pending",
      createdAt: old.createdAt,
    );

    final success = await provider.updateProduct(updatedProduct);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Edit Produk"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= IMAGE =================
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _newImageFile != null
                        ? Image.file(_newImageFile!, fit: BoxFit.cover)
                        : Image.network(_photoUrl, fit: BoxFit.cover),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= FORM CARD =================
              _card(
                child: Column(
                  children: [
                    _input(_nameCtrl, "Nama Produk",
                        validator: (v) =>
                            Validators.validateRequired(v, "nama produk")),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: "Kategori",
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (v) =>
                          setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 12),
                    _input(_descCtrl, "Deskripsi",
                        maxLines: 4,
                        validator: (v) =>
                            Validators.validateRequired(v, "deskripsi")),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _input(
                            _priceCtrl,
                            "Harga",
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                Validators.validateNumber(v, "harga"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _input(
                            _stockCtrl,
                            "Stok",
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                Validators.validateNumber(v, "stok"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _input(_brandCtrl, "Merek (Opsional)"),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: "Kondisi",
                      value: _selectedCondition,
                      items: _conditions,
                      onChanged: (v) =>
                          setState(() => _selectedCondition = v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= BUTTON =================
              ElevatedButton(
                onPressed: _saving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
