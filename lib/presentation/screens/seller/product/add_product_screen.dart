import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/product_provider.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();
  
  String _selectedCategory = 'Oli & Pelumas';
  String _selectedCondition = 'Baru';
  File? _selectedImage;
  bool _isLoading = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih gambar produk'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);

      // TODO: Upload image to Firebase Storage
      // For now, use placeholder
      final imageUrl = 'https://via.placeholder.com/300';

      // Create product
      final product = ProductModel(
        id: '',
        sellerId: authProvider.currentUser!.id,
        bengkelId: 'default', // TODO: Get from bengkel registration
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        photoUrl: imageUrl,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        condition: _selectedCondition,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      final success = await productProvider.addProduct(product);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan produk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, 
                              size: 64, 
                              color: Colors.grey[400]
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk pilih gambar',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Product Name
              CustomTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hintText: 'Contoh: Oli Castrol 10W-40',
                prefixIcon: Icons.inventory_2,
                validator: (value) => Validators.validateRequired(value, 'Nama produk'),
              ),
              
              const SizedBox(height: 16),
              
              // Category Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hintText: 'Jelaskan produk Anda...',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) => Validators.validateRequired(value, 'Deskripsi'),
              ),
              
              const SizedBox(height: 16),
              
              // Price & Stock Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Harga',
                      hintText: '75000',
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(value, 'Harga'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stok',
                      hintText: '20',
                      prefixIcon: Icons.inventory,
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(value, 'Stok'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Brand (Optional)
              CustomTextField(
                controller: _brandController,
                label: 'Merek (Opsional)',
                hintText: 'Contoh: Castrol, Yamalube',
                prefixIcon: Icons.branding_watermark,
              ),
              
              const SizedBox(height: 16),
              
              // Condition
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kondisi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCondition,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.new_releases),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _conditions.map((condition) {
                      return DropdownMenuItem(
                        value: condition,
                        child: Text(condition),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCondition = value!;
                      });
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              CustomButton(
                text: 'Simpan Produk',
                onPressed: _submitProduct,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}