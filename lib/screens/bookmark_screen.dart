import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/bookmark_model.dart';
import '../models/article_model.dart';
import 'article_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  String _sortBy = 'recent'; // recent, date, title

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookmarksData = await _databaseHelper.getBookmarks();
      final bookmarks = bookmarksData
          .map((data) => BookmarkModel.fromMap(data))
          .toList();

      // Sort bookmarks based on selected sorting option
      _sortBookmarks(bookmarks);

      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bookmarks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sortBookmarks(List<BookmarkModel> bookmarks) {
    switch (_sortBy) {
      case 'recent':
        bookmarks.sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
        break;
      case 'date':
        bookmarks.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case 'title':
        bookmarks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  Future<void> _removeBookmark(int index) async {
    final bookmark = _bookmarks[index];
    
    try {
      setState(() {
        _bookmarks.removeAt(index);
      });

      await _databaseHelper.removeBookmark(bookmark.articleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Bookmark removed'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                try {
                  await _databaseHelper.addBookmark(bookmark.toMap());
                  setState(() {
                    _bookmarks.insert(index, bookmark);
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to restore bookmark: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Restore the bookmark if removal failed
      setState(() {
        _bookmarks.insert(index, bookmark);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove bookmark: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeSelectedBookmarks() async {
    final indicesToRemove = _selectedIndices.toList()..sort((a, b) => b.compareTo(a));
    final bookmarksToRemove = <BookmarkModel>[];
    
    try {
      // Collect bookmarks to remove
      for (final index in indicesToRemove) {
        if (index < _bookmarks.length) {
          bookmarksToRemove.add(_bookmarks[index]);
        }
      }

      // Remove from database
      for (final bookmark in bookmarksToRemove) {
        await _databaseHelper.removeBookmark(bookmark.articleId);
      }

      // Remove from UI
      for (final index in indicesToRemove) {
        if (index < _bookmarks.length) {
          _bookmarks.removeAt(index);
        }
      }

      setState(() {
        _selectedIndices.clear();
        _isSelectionMode = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${bookmarksToRemove.length} bookmarks removed'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove bookmarks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Reload to ensure consistency
      await _loadBookmarks();
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _onArticleTap(BookmarkModel bookmark, int index) {
    if (_isSelectionMode) {
      _toggleSelection(index);
    } else {
      // Convert bookmark to article for detail screen
      final article = ArticleModel(
        title: bookmark.title,
        description: bookmark.description,
        imageUrl: bookmark.imageUrl,
        source: bookmark.source,
        publishedAt: bookmark.publishedAt,
        url: bookmark.url,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetailScreen(article: article),
        ),
      );
    }
  }

  void _onArticleLongPress(int index) {
    setState(() {
      _isSelectionMode = true;
      _selectedIndices.add(index);
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedIndices.clear();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Recently Added'),
              trailing: _sortBy == 'recent' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _sortBy = 'recent';
                });
                _loadBookmarks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Publication Date'),
              trailing: _sortBy == 'date' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _sortBy = 'date';
                });
                _loadBookmarks();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Title (A-Z)'),
              trailing: _sortBy == 'title' ? const Icon(Icons.check, color: Colors.blue) : null,
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _sortBy = 'title';
                });
                _loadBookmarks();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isSelectionMode 
            ? '${_selectedIndices.length} selected' 
            : 'Bookmarks'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _cancelSelection,
              )
            : null,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _selectedIndices.isEmpty 
                  ? null 
                  : _removeSelectedBookmarks,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: _showSortOptions,
            ),
          ],
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark_border,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              const Text(
                'No Bookmarks Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Save articles you want to read later by tapping the bookmark icon',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = _bookmarks[index];
        final isSelected = _selectedIndices.contains(index);

        return Dismissible(
          key: Key('bookmark_${bookmark.id}'),
          direction: _isSelectionMode 
              ? DismissDirection.none 
              : DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (_) => _removeBookmark(index),
          child: BookmarkCardInline(
            bookmark: bookmark,
            isSelected: isSelected,
            isSelectionMode: _isSelectionMode,
            onTap: () => _onArticleTap(bookmark, index),
            onLongPress: () => _onArticleLongPress(index),
          ),
        );
      },
    );
  }
}

class BookmarkCardInline extends StatelessWidget {
  final BookmarkModel bookmark;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BookmarkCardInline({
    Key? key,
    required this.bookmark,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection checkbox
              if (isSelectionMode)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected 
                        ? Icons.check_circle 
                        : Icons.circle_outlined,
                    color: isSelected ? Colors.blue : Colors.grey,
                    size: 24,
                  ),
                ),

              // Image
              if (bookmark.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    bookmark.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
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
                  child: const Icon(Icons.article, size: 40),
                ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      bookmark.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Source
                    Text(
                      bookmark.source,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Bookmarked time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: 12,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Saved ${_formatDate(bookmark.bookmarkedAt.toIso8601String())}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}