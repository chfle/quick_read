import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final NewsRepository _newsRepository = NewsRepository();
  
  final List<String> _categories = [
    'general',
    'technology',
    'business',
    'sports',
    'entertainment',
    'health',
    'science',
  ];
  
  String _selectedCategory = 'general';
  List<dynamic> _articles = []; // Replace with List<ArticleModel>
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // TODO: Uncomment when repository is connected
      // final articles = await _newsRepository.getTopHeadlines(
      //   category: _selectedCategory,
      //   pageSize: 20,
      // );
      
      // Simulating API call with delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock data for now
      final mockArticles = List.generate(10, (index) => {
        'title': 'Breaking News: Sample Article Title ${index + 1}',
        'description': 'This is a sample description for the article. It provides a brief overview of the content.',
        'source': 'News Source ${index % 3 + 1}',
        'publishedAt': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
        'urlToImage': index % 2 == 0 ? 'https://via.placeholder.com/300x200' : null,
        'url': 'https://example.com/article${index + 1}',
      });

      setState(() {
        _articles = mockArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchNews(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _searchQuery = query;
    });

    try {
      // TODO: Uncomment when repository is connected
      // final articles = await _newsRepository.searchNews(
      //   query: query,
      //   pageSize: 20,
      // );
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock search results
      final mockArticles = List.generate(5, (index) => {
        'title': 'Search Result: $query - Article ${index + 1}',
        'description': 'This article matches your search query for "$query".',
        'source': 'Search Source ${index % 2 + 1}',
        'publishedAt': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
        'urlToImage': 'https://via.placeholder.com/300x200',
        'url': 'https://example.com/search${index + 1}',
      });

      setState(() {
        _articles = mockArticles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _isSearching = false;
      _searchQuery = '';
    });
    _loadNews();
  }

  Future<void> _onRefresh() async {
    if (_isSearching && _searchQuery.isNotEmpty) {
      await _searchNews(_searchQuery);
    } else {
      await _loadNews();
    }
  }

  void _onArticleTap(dynamic article) {
    // TODO: Navigate to article detail screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ArticleDetailScreen(article: article),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: ${article['title']}')),
    );
  }

  void _onBookmarkToggle(dynamic article) {
    // TODO: Implement bookmark toggle
    // await _newsRepository.toggleBookmark(article);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bookmark toggled'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('News Feed'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _loadNews();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (_isSearching)
            SearchBarWidgetInline(
              onSearch: _searchNews,
              onClear: () {
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                });
                _loadNews();
              },
            ),

          // Category tabs
          if (!_isSearching)
            CategoryTabBarInline(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),

          // News feed
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.blue,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          
          // Show expanded card for first article
          if (index == 0) {
            return NewsCardExpandedInline(
              article: article,
              onTap: () => _onArticleTap(article),
              onBookmarkToggle: () => _onBookmarkToggle(article),
            );
          }
          
          return NewsCardCompactInline(
            article: article,
            onTap: () => _onArticleTap(article),
            onBookmarkToggle: () => _onBookmarkToggle(article),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => const ShimmerCardInline(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load news. Please check your connection.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            const Text(
              'No articles found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _isSearching
                  ? 'Try a different search term'
                  : 'No news available for this category',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Inline widgets (simplified versions)

class SearchBarWidgetInline extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const SearchBarWidgetInline({
    Key? key,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);

  @override
  State<SearchBarWidgetInline> createState() => _SearchBarWidgetInlineState();
}

class _SearchBarWidgetInlineState extends State<SearchBarWidgetInline> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search news...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onClear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}

class CategoryTabBarInline extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryTabBarInline({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          
          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  category[0].toUpperCase() + category.substring(1),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewsCardCompactInline extends StatelessWidget {
  final dynamic article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const NewsCardCompactInline({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (article['urlToImage'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article['urlToImage'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.article),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article['source'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: onBookmarkToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsCardExpandedInline extends StatelessWidget {
  final dynamic article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const NewsCardExpandedInline({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmarkToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article['urlToImage'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (article['description'] != null)
                    Text(
                      article['description'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 3,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article['source'],
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_border),
                        onPressed: onBookmarkToggle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerCardInline extends StatelessWidget {
  const ShimmerCardInline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Container(height: 12, width: 80, color: Colors.grey[300]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}