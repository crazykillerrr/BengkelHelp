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

  // ===========================================================
  // INIT
  // ===========================================================

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
    final orders = provider.orders.where((order) {
      if (status == OrderStatus.onProgress) {
        // Diproses = confirmed + onProgress
        return order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.onProgress;
      }
      return order.status == status;
    }).toList();

    if (orders.isEmpty) {
      return _emptyState();
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

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesanan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
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
              _orderHeader(order),
              const SizedBox(height: 16),
              _orderItemsPreview(order),
              const Divider(height: 24),
              _orderFooter(order),
              _orderActionButtons(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderHeader(OrderModel order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order #${order.id.substring(0, 8)}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        _buildStatusBadge(order.status),
      ],
    );
  }

  Widget _orderItemsPreview(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...order.items.take(2).map(
              (item) => Padding(
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
              ),
            ),
        if (order.items.length > 2)
          Text(
            "+${order.items.length - 2} produk lainnya",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _orderFooter(OrderModel order) {
    return Row(
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _orderActionButtons(OrderModel order) {
    if (order.status == OrderStatus.pending) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _rejectOrder(order),
                style:
                    OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Tolak"),
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
      );
    }

    if (order.status == OrderStatus.onProgress) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text("Selesaikan Pesanan"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => _completeOrder(order),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ===========================================================
  // IMAGE
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
    late Color color;
    late String text;

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
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  // ===========================================================
  // ACTIONS
  // ===========================================================

  Future<void> _acceptOrder(OrderModel order) async {
    if (!await _confirmDialog("Terima Pesanan",
        "Yakin ingin menerima pesanan ini?")) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, OrderStatus.onProgress);
    await _loadOrders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pesanan diproses"), backgroundColor: Colors.green),
    );
  }

  Future<void> _completeOrder(OrderModel order) async {
    if (!await _confirmDialog("Selesaikan Pesanan",
        "Yakin pesanan ini sudah selesai?")) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, OrderStatus.completed);
    await _loadOrders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pesanan selesai"), backgroundColor: Colors.green),
    );
  }

  Future<void> _rejectOrder(OrderModel order) async {
    if (!await _confirmDialog(
      "Tolak Pesanan",
      "Yakin ingin menolak pesanan ini?",
      destructive: true,
    )) return;

    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.updateOrderStatus(order.id, OrderStatus.cancelled);
    await _loadOrders();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Pesanan ditolak"),
          backgroundColor: Colors.orange),
    );
  }

  Future<bool> _confirmDialog(
    String title,
    String message, {
    bool destructive = false,
  }) async {
    return await showDialog<bool>(
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
                  backgroundColor:
                      destructive ? Colors.red : AppColors.primary,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showOrderDetail(OrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                // drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Detail Pesanan",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Order #${order.id}",
                  style: TextStyle(color: Colors.grey[600]),
                ),

                const Divider(height: 30),

                _buildStatusBadge(order.status),

                const SizedBox(height: 20),

                const Text(
                  "Daftar Produk",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

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
                          child: Text(item.productName),
                        ),
                        Text(
                          "${item.quantity} x ${CurrencyFormatter.format(item.price)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }),

                const Divider(height: 30),

                _buildPriceRow("Subtotal", order.subtotal ?? 0),
                _buildPriceRow("Ongkir", order.deliveryFee ?? 0),
                const Divider(),
                _buildPriceRow(
                  "Total",
                  order.totalAmount,
                  isTotal: true,
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      );
    },
  );
}
  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
