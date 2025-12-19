import 'package:flutter/material.dart';

class ReminderDetailScreen extends StatefulWidget {
  const ReminderDetailScreen({super.key});

  @override
  State<ReminderDetailScreen> createState() => _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends State<ReminderDetailScreen> {
  // ================= CONTROLLERS =================
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _repeatController = TextEditingController();
  final TextEditingController _ringtoneController = TextEditingController();

  bool _isVibrationActive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B238F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Pengingat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ================= ILLUSTRATION =================
            Center(
              child: Image.network(
                'https://i.imgur.com/yZQZJ9y.png',
                height: 200,
              ),
            ),

            const SizedBox(height: 30),

            _inputItem('Nama Pengingat', _nameController, 'Contoh: Ganti Oli'),
            _divider(),

            Row(
              children: [
                Expanded(
                  child: _inputItem(
                    'Tanggal',
                    _dateController,
                    'Pilih tanggal',
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _inputItem(
                    'Waktu',
                    _timeController,
                    'Pilih waktu',
                    readOnly: true,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            _divider(),

            _inputItem(
              'Ulangi',
              _repeatController,
              'Contoh: Setiap 3 bulan',
            ),
            _divider(),

            _inputItem(
              'Nada Dering',
              _ringtoneController,
              'Pilih nada dering',
            ),
            _divider(),

            // ================= GETARAN =================
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Getaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Switch(
                    value: _isVibrationActive,
                    onChanged: (value) {
                      setState(() {
                        _isVibrationActive = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            _divider(),

            const SizedBox(height: 30),

            // ================= SAVE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B238F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _confirmSave,
                child: const Text(
                  'Simpan Pengingat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INPUT ITEM =================
  Widget _inputItem(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 28, thickness: 1);
  }

  // ================= DATE PICKER =================
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      _dateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  // ================= TIME PICKER =================
  Future<void> _pickTime() async {
    final picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      _timeController.text =
          "${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}";
    }
  }

  // ================= CONFIRM SAVE =================
  void _confirmSave() {
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi data pengingat')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Simpan Pengingat'),
        content:
            const Text('Apakah kamu yakin ingin menyimpan pengingat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
