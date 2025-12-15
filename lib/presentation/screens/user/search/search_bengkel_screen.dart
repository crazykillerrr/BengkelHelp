import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../widgets/bengkel/bengkel_card.dart';
import '../../../navigation/app_router.dart';

class SearchBengkelScreen extends StatefulWidget {
  const SearchBengkelScreen({super.key});

  @override
  State<SearchBengkelScreen> createState() => _SearchBengkelScreenState();
}

class _SearchBengkelScreenState extends State<SearchBengkelScreen> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  List results = [];

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => results = []);
      return;
    }

    setState(() => _isSearching = true);

    final provider = Provider.of<BengkelProvider>(context, listen: false);
    final data = await provider.searchBengkels(query);

    setState(() {
      results = data;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Cari bengkel...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: _search,
          ),
        ),

        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
                  ? const Center(child: Text('Tidak ada bengkel'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: results.length,
                      itemBuilder: (_, i) {
                        final bengkel = results[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: BengkelCard(
                            bengkel: bengkel,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.bengkelDetail,
                                arguments: bengkel.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
