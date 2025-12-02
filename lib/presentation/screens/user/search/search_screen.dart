import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../widgets/bengkel/bengkel_card.dart';
import '../../../navigation/app_router.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
    });
    
    final bengkelProvider = Provider.of<BengkelProvider>(context, listen: false);
    final results = await bengkelProvider.searchBengkels(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Cari Bengkel'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusXL),
                bottomRight: Radius.circular(AppTheme.radiusXL),
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Cari bengkel atau layanan...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textHint,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _performSearch(value);
              },
            ),
          ),
          
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 64,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Cari bengkel atau layanan'
                                  : 'Tidak ada hasil',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingL),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final bengkel = _searchResults[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: BengkelCard(
                              bengkel: bengkel,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.booking,
                                  arguments: {'bengkelId': bengkel.id},
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}