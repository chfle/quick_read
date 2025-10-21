import 'package:flutter/material.dart';
import '../services/news_api_service.dart';
import '../models/article_model.dart';
import '../database/database_helper.dart';
import 'article_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NewsApiService _newsApiService = NewsApiService();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
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
  List<ArticleModel> _articles = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSearching = false;
  String _searchQuery = '';
  Map<String, bool> _bookmarkedArticles = {};

  @override
  void initState() {
    super.initState();
    _loadNews();
    _loadBookmarkStatus();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await _newsApiService.getTopHeadlines(
        category: _selectedCategory,
        pageSize: 20,
      );

      if (response['status'] == 'ok') {
        final List<dynamic> articlesJson = response['articles'] ?? [];
        final articles = articlesJson
            .map((json) => ArticleModel.fromNewsApi(json))
            .toList();

        setState(() {
          _articles = articles;
          _isLoading = false;
        });
        
        _loadBookmarkStatus();
      } else {
        throw Exception('API returned error status');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error loading news: $e');
    }
  }

  Future<void> _loadBookmarkStatus() async {
    try {
      final bookmarkedStatus = <String, bool>{};
      for (final article in _articles) {
        final articleId = article.url.hashCode.toString();
        final isBookmarked = await _databaseHelper.isBookmarked(articleId);
        bookmarkedStatus[articleId] = isBookmarked;
      }
      
      setState(() {
        _bookmarkedArticles = bookmarkedStatus;
      });
    } catch (e) {
      print('Error loading bookmark status: $e');
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
      final response = await _newsApiService.searchNews(
        query: query,
        pageSize: 20,
      );

      if (response['status'] == 'ok') {
        final List<dynamic> articlesJson = response['articles'] ?? [];
        final articles = articlesJson
            .map((json) => ArticleModel.fromNewsApi(json))
            .toList();

        setState(() {
          _articles = articles;
          _isLoading = false;
        });
        
        _loadBookmarkStatus();
      } else {
        throw Exception('API returned error status');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error searching news: $e');
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

  void _onArticleTap(ArticleModel article) async {
    try {
      // Add to reading history
      await _databaseHelper.addToHistory({
        'articleId': article.url.hashCode.toString(),
        'title': article.title,
        'imageUrl': article.imageUrl,
        'source': article.source,
        'url': article.url,
        'readAt': DateTime.now().toIso8601String(),
      });

      // Navigate to article detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(article: article),
        ),
      );
    } catch (e) {
      print('Error adding to history: $e');
      // Still navigate even if history fails
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(article: article),
        ),
      );
    }
  }

  void _onBookmarkToggle(ArticleModel article) async {
    try {
      final articleId = article.url.hashCode.toString();
      final isCurrentlyBookmarked = _bookmarkedArticles[articleId] ?? false;

      if (isCurrentlyBookmarked) {
        await _databaseHelper.removeBookmark(articleId);
        setState(() {
          _bookmarkedArticles[articleId] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await _databaseHelper.addBookmark({
          'articleId': articleId,
          'title': article.title,
          'description': article.description,
          'imageUrl': article.imageUrl,
          'source': article.source,
          'publishedAt': article.publishedAt,
          'url': article.url,
          'bookmarkedAt': DateTime.now().toIso8601String(),
        });
        setState(() {
          _bookmarkedArticles[articleId] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating bookmark'),
          duration: Duration(seconds: 1),
        ),
      );
    }
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
          final articleId = article.url.hashCode.toString();
          final isBookmarked = _bookmarkedArticles[articleId] ?? false;
          
          // Show expanded card for first article
          if (index == 0) {
            return NewsCardExpandedInline(
              article: article,
              isBookmarked: isBookmarked,
              onTap: () => _onArticleTap(article),
              onBookmarkToggle: () => _onBookmarkToggle(article),
            );
          }
          
          return NewsCardCompactInline(
            article: article,
            isBookmarked: isBookmarked,
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
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;
  final bool isBookmarked;

  const NewsCardCompactInline({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmarkToggle,
    this.isBookmarked = false,
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
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.imageUrl!,
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
                      article.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.source,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.blue : null,
                ),
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
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;
  final bool isBookmarked;

  const NewsCardExpandedInline({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onBookmarkToggle,
    this.isBookmarked = false,
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
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (article.description != null)
                    Text(
                      article.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 3,
                    ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.blue : null,
                        ),
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