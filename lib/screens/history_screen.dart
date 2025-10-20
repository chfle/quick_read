import 'package:flutter/material.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // final NewsRepository _newsRepository = NewsRepository();
  
  List<dynamic> _history = []; // Replace with List<ReadingHistoryModel>
  bool _isLoading = false;
  String _filter = 'all'; // all, today, week, month

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Uncomment when repository is connected
      // final history = await _newsRepository.getReadingHistory();
      
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock history data
      final mockHistory = List.generate(15, (index) => {
        'id': index,
        'articleId': 'article_$index',
        'title': 'Read Article ${index + 1}: News story you viewed recently',
        'imageUrl': index % 3 != 0 ? 'https://via.placeholder.com/300x200' : null,
        'source': 'News Source ${index % 4 + 1}',
        'url': 'https://example.com/article${index + 1}',
        'readAt': DateTime.now().subtract(Duration(
          hours: index < 5 ? index * 2 : 24,
          days: index < 5 ? 0 : index - 4,
        )).toIso8601String(),
      });

      setState(() {
        _history = mockHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteHistoryItem(int index) async {
    final item = _history[index];
    
    setState(() {
      _history.removeAt(index);
    });

    // TODO: Uncomment when repository is connected
    // await _newsRepository.deleteHistoryItem(item['id']);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item removed from history'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() {
                _history.insert(index, item);
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmedClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
          'Are you sure you want to clear all reading history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmedClear == true) {
      setState(() {
        _history.clear();
      });

      // TODO: Uncomment when repository is connected
      // await _newsRepository.clearHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  void _onArticleTap(dynamic historyItem) {
    // TODO: Navigate to article detail
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ArticleDetailScreen(article: historyItem),
    //   ),
    // );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: ${historyItem['title']}')),
    );
  }

  List<dynamic> get _filteredHistory {
    final now = DateTime.now();
    
    switch (_filter) {
      case 'today':
        return _history.where((item) {
          final readAt = DateTime.parse(item['readAt']);
          return readAt.year == now.year &&
                 readAt.month == now.month &&
                 readAt.day == now.day;
        }).toList();
      
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _history.where((item) {
          final readAt = DateTime.parse(item['readAt']);
          return readAt.isAfter(weekAgo);
        }).toList();
      
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return _history.where((item) {
          final readAt = DateTime.parse(item['readAt']);
          return readAt.isAfter(monthAgo);
        }).toList();
      
      default:
        return _history;
    }
  }

  void _showFilterOptions() {
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
                  'Filter History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildFilterOption('All Time', 'all', Icons.history),
            _buildFilterOption('Today', 'today', Icons.today),
            _buildFilterOption('This Week', 'week', Icons.date_range),
            _buildFilterOption('This Month', 'month', Icons.calendar_month),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, String value, IconData icon) {
    final isSelected = _filter == value;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey[700],
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _filter = value;
        });
        Navigator.pop(context);
      },
    );
  }

  String _getFilterLabel() {
    switch (_filter) {
      case 'today':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      default:
        return 'All Time';
    }
  }

  Map<String, List<dynamic>> _groupByDate(List<dynamic> items) {
    final Map<String, List<dynamic>> grouped = {};
    final now = DateTime.now();

    for (final item in items) {
      final readAt = DateTime.parse(item['readAt']);
      String key;

      if (readAt.year == now.year && 
          readAt.month == now.month && 
          readAt.day == now.day) {
        key = 'Today';
      } else if (readAt.isAfter(now.subtract(const Duration(days: 1))) &&
                 readAt.day == now.day - 1) {
        key = 'Yesterday';
      } else if (readAt.isAfter(now.subtract(const Duration(days: 7)))) {
        key = 'This Week';
      } else if (readAt.isAfter(now.subtract(const Duration(days: 30)))) {
        key = 'This Month';
      } else {
        key = 'Older';
      }

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Reading History'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAllHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter chip
          if (_filter != 'all')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(_getFilterLabel()),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _filter = 'all';
                      });
                    },
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredItems = _filteredHistory;

    if (filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              Text(
                _filter == 'all' 
                    ? 'No Reading History' 
                    : 'No Articles Read',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _filter == 'all'
                    ? 'Articles you read will appear here'
                    : 'No articles read during this period',
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

    final groupedHistory = _groupByDate(filteredItems);
    final sortedKeys = ['Today', 'Yesterday', 'This Week', 'This Month', 'Older']
        .where((key) => groupedHistory.containsKey(key))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedKeys.length,
      itemBuilder: (context, sectionIndex) {
        final sectionKey = sortedKeys[sectionIndex];
        final sectionItems = groupedHistory[sectionKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                sectionKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            
            // Section items
            ...sectionItems.asMap().entries.map((entry) {
              final itemIndex = entry.key;
              final item = entry.value;
              final globalIndex = _history.indexOf(item);

              return Dismissible(
                key: Key('history_${item['id']}'),
                direction: DismissDirection.endToStart,
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
                onDismissed: (_) => _deleteHistoryItem(globalIndex),
                child: HistoryCardInline(
                  item: item,
                  onTap: () => _onArticleTap(item),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class HistoryCardInline extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const HistoryCardInline({
    Key? key,
    required this.item,
    required this.onTap,
  }) : super(key: key);

  String _formatReadTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
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
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              if (item['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['imageUrl'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 30),
                    ),
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.article, size: 35),
                ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Source
                    Text(
                      item['source'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Read time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Read ${_formatReadTime(item['readAt'])}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
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