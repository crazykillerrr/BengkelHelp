import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';

class RegisterBengkelScreen extends StatefulWidget {
  const RegisterBengkelScreen({super.key});

  @override
  State<RegisterBengkelScreen> createState() => _RegisterBengkelScreenState();
}

class _RegisterBengkelScreenState extends State<RegisterBengkelScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _openTime = TextEditingController();
  final _closeTime = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _phone.dispose();
    _openTime.dispose();
    _closeTime.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  final auth = context.read<AuthProvider>();
  final user = auth.currentUser;
  if (user == null) return;

  setState(() => _loading = true);

  try {
    // 🔥 DEBUG WAJIB
    debugPrint('🔥 Writing to collection: bengkels');

    await FirebaseFirestore.instance
        .collection('bengkels') // HARUS bengkels
        .add({
      'ownerId': user.id,
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'address': _address.text.trim(),
      'phone': _phone.text.trim(),
      'latitude': 0.0,
      'longitude': 0.0,
      'openTime': _openTime.text.trim(),
      'closeTime': _closeTime.text.trim(),
      'operatingHours': {},
      'photoUrl': null,
      'services': [],
      'status': 'verified',
      'isActive': true,
      'rating': 0.0,
      'totalReviews': 0,
      'createdAt': Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bengkel berhasil didaftarkan')),
    );

    Navigator.pop(context);
  } catch (e) {
    debugPrint('❌ ERROR REGISTER BENGKEL: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal: $e')),
    );
  } finally {
    setState(() => _loading = false);
  }
}


  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Bengkel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_name, 'Nama Bengkel', Icons.store),
              _field(_description, 'Deskripsi', Icons.description),
              _field(_address, 'Alamat', Icons.location_on),
              _field(
                _phone,
                'No Telepon',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _field(
                _openTime,
                'Jam Buka (08:00)',
                Icons.access_time,
              ),
              _field(
                _closeTime,
                'Jam Tutup (17:00)',
                Icons.access_time,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Daftarkan Bengkel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
