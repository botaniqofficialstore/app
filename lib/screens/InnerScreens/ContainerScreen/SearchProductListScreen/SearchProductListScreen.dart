import 'package:botaniqmicrogreens/CodeReusable/CodeReusability.dart';
import 'package:flutter/material.dart';

class SearchProductListScreen extends StatefulWidget {
  const SearchProductListScreen({super.key});

  @override
  State<SearchProductListScreen> createState() => _DedicatedSearchScreenState();
}

class _DedicatedSearchScreenState extends State<SearchProductListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data - In a real app, this comes from an API or Local DB
  final List<String> _allProducts = [
    'iPhone 15 Pro', 'Samsung S24 Ultra', 'MacBook Air M3',
    'Nike Air Max', 'Adidas Ultraboost', 'Sony WH-1000XM5',
    'Logitech MX Master 3', 'Dell XPS 13'
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = [];
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = _allProducts
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CodeReusability.hideKeyboard(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true, // Keyboard opens immediately
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search for products...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
        body: _filteredSuggestions.isEmpty && _searchController.text.isNotEmpty
            ? _buildNoResult()
            : _buildSuggestions(),
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredSuggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _filteredSuggestions[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history, color: Colors.grey), // or Icons.trending_up
          title: Text(item, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.north_west, size: 18, color: Colors.grey),
          onTap: () {
            // Handle final search selection
            print("Selected: $item");
          },
        );
      },
    );
  }

  Widget _buildNoResult() {
    return const Center(
      child: Text("No products found.", style: TextStyle(color: Colors.grey)),
    );
  }
}


