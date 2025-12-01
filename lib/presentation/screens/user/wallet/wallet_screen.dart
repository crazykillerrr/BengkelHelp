import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/wallet_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _amountController = TextEditingController();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      walletProvider.loadBalance(authProvider.currentUser!.id);
      walletProvider.loadTransactions(authProvider.currentUser!.id);
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  void _showTopUpDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXL),
            topRight: Radius.circular(AppTheme.radiusXL),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Top Up BengkelPay', style: AppTheme.h3),
              const SizedBox(height: AppTheme.spacingL),
              
              CustomTextField(
                controller: _amountController,
                label: 'Jumlah',
                hintText: 'Masukkan jumlah top up',
                prefixIcon: Icons.money,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Wrap(
                spacing: AppTheme.spacingS,
                runSpacing: AppTheme.spacingS,
                children: [50000, 100000, 200000, 500000].map((amount) {
                  return GestureDetector(
                    onTap: () {
                      _amountController.text = amount.toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        currencyFormat.format(amount),
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              CustomButton(
                text: 'Top Up',
                onPressed: () async {
                  final amount = double.tryParse(_amountController.text);
                  if (amount == null || amount < AppConstants.minTopUpAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Minimal top up ${currencyFormat.format(AppConstants.minTopUpAmount)}'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                    return;
                  }
                  
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final walletProvider = Provider.of<WalletProvider>(context, listen: false);
                  
                  final success = await walletProvider.topUp(
                    authProvider.currentUser!.id,
                    amount,
                  );
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Top up berhasil' : 'Top up gagal'),
                        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                      ),
                    );
                    
                    _amountController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('BengkelPay'),
        elevation: 0,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, _) {
          return Column(
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.all(AppTheme.spacingL),
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo BengkelPay',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      currencyFormat.format(walletProvider.balance),
                      style: AppTheme.h1.copyWith(
                        color: Colors.white,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showTopUpDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                        child: const Text('Top Up Saldo'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Transactions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Riwayat Transaksi', style: AppTheme.h3),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              Expanded(
                child: walletProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : walletProvider.transactions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt_long,
                                  size: 64,
                                  color: AppTheme.textHint,
                                ),
                                const SizedBox(height: AppTheme.spacingM),
                                Text(
                                  'Belum ada transaksi',
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                            itemCount: walletProvider.transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = walletProvider.transactions[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                                padding: const EdgeInsets.all(AppTheme.spacingM),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                                  boxShadow: AppTheme.shadowLight,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppTheme.spacingM),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                      ),
                                      child: Icon(
                                        transaction['type'] == 'topup' 
                                            ? Icons.add_circle
                                            : Icons.remove_circle,
                                        color: transaction['type'] == 'topup'
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.spacingM),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            transaction['type'] == 'topup' 
                                                ? 'Top Up'
                                                : 'Pembayaran',
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy, HH:mm').format(
                                              (transaction['createdAt'] as Timestamp).toDate(),
                                            ),
                                            style: AppTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${transaction['type'] == 'topup' ? '+' : '-'} ${currencyFormat.format(transaction['amount'])}',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: transaction['type'] == 'topup'
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}