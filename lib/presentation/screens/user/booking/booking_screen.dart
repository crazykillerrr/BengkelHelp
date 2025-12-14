import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/bengkel_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_item.dart';
import '../../../widgets/common/custom_button.dart';

class BookingScreen extends StatefulWidget {
  final String? bengkelId;
  
  const BookingScreen({super.key, this.bengkelId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BengkelModel? _bengkel;
  String? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _notesController = TextEditingController();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadBengkel();
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBengkel() async {
    if (widget.bengkelId != null) {
      final bengkelProvider = Provider.of<BengkelProvider>(context, listen: false);
      final bengkel = await bengkelProvider.getBengkelById(widget.bengkelId!);
      setState(() {
        _bengkel = bengkel;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }
  
  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }
  
  Future<void> _createBooking() async {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih layanan terlebih dahulu'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal dan waktu terlebih dahulu'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    

    

    final order = OrderModel(
      id: '',
      userId: authProvider.currentUser!.id,
      sellerId: _bengkel!.ownerId,
      bengkelId: _bengkel!.id,
      type: 'service',
      items: [
        OrderItem(
          productId: _selectedService!,
          productName: _selectedService!,
          photoUrl: null,
          price: 0,
          quantity: 1,
        ),
      ],
      totalAmount: 0,
      status: OrderStatus.pending,
      paymentMethod: AppConstants.paymentBengkelPay,
      createdAt: DateTime.now(),
    );

    
    final success = await orderProvider.createOrder(order);
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibuat'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat booking'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_bengkel == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: Text('Bengkel tidak ditemukan')),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Booking Montir'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bengkel Info
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusXL),
                  bottomRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: _bengkel!.photoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            child: Image.network(
                              _bengkel!.photoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.build_circle,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _bengkel!.name,
                          style: AppTheme.h3.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.accentColor, size: 16),
                            const SizedBox(width: AppTheme.spacingXS),
                            Text(
                              _bengkel!.rating.toStringAsFixed(1),
                              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Service Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Layanan', style: AppTheme.h3),
                  const SizedBox(height: AppTheme.spacingM),
                  ...AppConstants.serviceCategories.map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                      // Using RadioListTile API (groupValue/onChanged) — marked deprecated
                      // ignore: deprecated_member_use
                      child: RadioListTile<String>(
                        title: Text(service),
                        value: service,
                        groupValue: _selectedService, // ignore: deprecated_member_use
                        onChanged: (value) { // ignore: deprecated_member_use
                          setState(() {
                            _selectedService = value;
                          });
                        },
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                      ),
                    );
                  }),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Date & Time
                  const Text('Pilih Tanggal & Waktu', style: AppTheme.h3),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today),
                                const SizedBox(width: AppTheme.spacingM),
                                Text(
                                  _selectedDate != null
                                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                      : 'Pilih Tanggal',
                                  style: AppTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectTime,
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: AppTheme.spacingM),
                                Text(
                                  _selectedTime != null
                                      ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Pilih Waktu',
                                  style: AppTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                  
                  // Notes
                  const Text('Catatan (Opsional)', style: AppTheme.h3),
                  const SizedBox(height: AppTheme.spacingM),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan untuk montir...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppTheme.spacingXL),
                  
                  CustomButton(
                    text: 'Buat Booking',
                    onPressed: _createBooking,
                  ),
                  
                  const SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}