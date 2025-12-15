import 'package:flutter/material.dart';
import 'search_bengkel_screen.dart';
import 'search_produk_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pencarian'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bengkel'),
              Tab(text: 'Produk'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SearchBengkelScreen(),
            SearchProdukScreen(),
          ],
        ),
      ),
    );
  }
}
