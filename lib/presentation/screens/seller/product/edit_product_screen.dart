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

  // LOAD PRODUCT DATA
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
      setState(() {
        _newImageFile = File(img.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final provider = Provider.of<ProductProvider>(context, listen: false);

    // NOTE:
    // Upload gambar ke Firebase Storage jika _newImageFile != null
    // Di sini sementara pakai image lama (_photoUrl)

    final updatedProduct = ProductModel(
      id: widget.productId,
      sellerId: provider.products.firstWhere((p) => p.id == widget.productId).sellerId,
      bengkelId: provider.products.firstWhere((p) => p.id == widget.productId).bengkelId,
      name: _nameCtrl.text,
      description: _descCtrl.text,
      category: _selectedCategory,
      price: double.parse(_priceCtrl.text),
      stock: int.parse(_stockCtrl.text),
      photoUrl: _photoUrl, // TODO: replace with uploaded URL if needed
      brand: _brandCtrl.text.isNotEmpty ? _brandCtrl.text : null,
      condition: _selectedCondition,
      status: "pending",
      createdAt: provider.products.firstWhere((p) => p.id == widget.productId).createdAt,
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
      appBar: AppBar(
        title: const Text("Edit Produk"),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // IMAGE PICKER
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _newImageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_newImageFile!, fit: BoxFit.cover),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_photoUrl, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // NAME
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Nama Produk"),
                validator: (v) => Validators.validateRequired(v, "nama produk"),
              ),

              const SizedBox(height: 12),

              // CATEGORY
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: "Kategori"),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),

              const SizedBox(height: 12),

              // DESCRIPTION
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                validator: (v) => Validators.validateRequired(v, "deskripsi"),
              ),

              const SizedBox(height: 12),

              // PRICE & STOCK
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Harga"),
                      validator: (v) => Validators.validateNumber(v, "harga"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Stok"),
                      validator: (v) => Validators.validateNumber(v, "stok"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // BRAND
              TextFormField(
                controller: _brandCtrl,
                decoration:
                    const InputDecoration(labelText: "Merek (Opsional)"),
              ),

              const SizedBox(height: 12),

              // CONDITION
              DropdownButtonFormField(
                value: _selectedCondition,
                decoration: const InputDecoration(labelText: "Kondisi"),
                items: _conditions.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCondition = v!),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(fontSize: 16),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
