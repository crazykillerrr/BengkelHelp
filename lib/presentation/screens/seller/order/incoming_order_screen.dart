import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/order_model.dart';

class IncomingOrderScreen extends StatefulWidget {
  const IncomingOrderScreen({Key? key}) : super(key: key);

  @override
  State<IncomingOrderScreen> createState() => _IncomingOrderScreenState();
}

class _IncomingOrderScreenState extends State<IncomingOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await orderProvider.fetchSellerOrders(authProvider.currentUser!.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ===========================================================
  // MAIN UI
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Diproses'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),

      body: Consumer<OrderProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(provider, OrderStatus.pending),
              _buildOrderList(provider, OrderStatus.onProgress),
              _buildOrderList(provider, OrderStatus.completed),
              _buildOrderList(provider, OrderStatus.cancelled),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================
  // ORDER LIST
  // ===========================================================

  Widget _buildOrderList(OrderProvider provider, OrderStatus status) {
    final orders = provider.orders
        .where((order) => order.status == status)
        .toList();

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Tidak ada pesanan',
              style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _buildOrderCard(orders[i]),
      ),
    );
  }

  // ===========================================================
  // ORDER CARD
  // ===========================================================

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Header -------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order.id.substring(0, 8)}",
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(order.status),
                ],
              ),

              const SizedBox(height: 16),

              // Items Preview ------------------------------------------------
              ...order.items.take(2).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildItemImage(item.photoUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
                      ),
                    ),
                    Text("${item.quantity}x"),
                  ],
                ),
              )),

              if (order.items.length > 2)
                Text(
                  "+${order.items.length - 2} produk lainnya",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const Divider(height: 24),

              // Footer -------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormatter.formatDate(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              if (order.status == OrderStatus.pending) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _rejectOrder(order),
                        child: const Text("Tolak"),
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _acceptOrder(order),
                        child: const Text("Terima"),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // IMAGE BUILDER
  // ===========================================================

  Widget _buildItemImage(String? url) {
    if (url == null || url.isEmpty) {
      return _fallbackImage();
    }
    return Image.network(
      url,
      width: 45,
      height: 45,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      width: 45,
      height: 45,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 20),
    );
  }

  // ===========================================================
  // STATUS BADGE
  // ===========================================================

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        text = 'Baru';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        text = 'Dikonfirmasi';
        break;
      case OrderStatus.onProgress:
        color = AppColors.secondary;
        text = 'Diproses';
        break;
      case OrderStatus.completed:
        color = AppColors.success;
        text = 'Selesai';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ===========================================================
  // ORDER DETAIL (BOTTOM SHEET)
  // ===========================================================

  void _showOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text("Detail Pesanan",
                      style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("Order #${order.id}",
                      style: TextStyle(color: Colors.grey[600])),

                  const Divider(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Status:",
                          style: TextStyle(fontSize: 16)),
                      _buildStatusBadge(order.status),
                    ],
                  ),

                  if (order.deliveryAddress != null) ...[
                    const SizedBox(height: 20),
                    const Text("Alamat Pengiriman",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Expanded(child: Text(order.deliveryAddress!)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Text("Produk:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),

                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: _buildItemImage(item.photoUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            CurrencyFormatter.format(
                                item.price * item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),

                  const Divider(height: 30),

                  _buildPriceRow("Subtotal", order.subtotal ?? 0),
                  const SizedBox(height: 6),
                  _buildPriceRow("Biaya Kirim", order.deliveryFee ?? 0),
                  const Divider(height: 25),
                  _buildPriceRow("Total", order.totalAmount, isTotal: true),

                  const SizedBox(height: 25),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(CurrencyFormatter.format(value),
            style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppColors.primary : Colors.black)),
      ],
    );
  }

  // ===========================================================
  // ACTION HANDLERS
  // ===========================================================

  Future<void> _acceptOrder(OrderModel order) async {
    bool? confirm = await _confirmDialog(
      "Terima Pesanan",
      "Yakin ingin menerima pesanan ini?",
    );
    if (confirm != true) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success = await provider.updateOrderStatus(
      order.id,
      OrderStatus.confirmed,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Pesanan diterima" : "Gagal menerima pesanan"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _rejectOrder(OrderModel order) async {
    bool? confirm = await _confirmDialog(
      "Tolak Pesanan",
      "Yakin ingin menolak pesanan ini?",
      destructive: true,
    );
    if (confirm != true) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, OrderStatus.cancelled);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pesanan ditolak"), backgroundColor: Colors.orange),
    );
  }

  Future<bool?> _confirmDialog(String title, String message,
      {bool destructive = false}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: destructive ? Colors.red : AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }
}
