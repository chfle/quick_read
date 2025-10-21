import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../database/database_helper.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;
  
  const ArticleDetailScreen({
    Key? key,
    required this.article,
  }) : super(key: key);

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  bool _isBookmarked = false;
  bool _isLoadingBookmark = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _addToHistory();
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final articleId = widget.article.url.hashCode.toString();
      final isBookmarked = await _databaseHelper.isBookmarked(articleId);
      
      setState(() {
        _isBookmarked = isBookmarked;
      });
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _addToHistory() async {
    try {
      await _databaseHelper.addToHistory({
        'articleId': widget.article.url.hashCode.toString(),
        'title': widget.article.title,
        'imageUrl': widget.article.imageUrl,
        'source': widget.article.source,
        'url': widget.article.url,
        'readAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding to history: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    setState(() {
      _isLoadingBookmark = true;
    });

    try {
      final articleId = widget.article.url.hashCode.toString();
      
      if (_isBookmarked) {
        await _databaseHelper.removeBookmark(articleId);
        setState(() {
          _isBookmarked = false;
          _isLoadingBookmark = false;
        });
      } else {
        await _databaseHelper.addBookmark({
          'articleId': articleId,
          'title': widget.article.title,
          'description': widget.article.description,
          'imageUrl': widget.article.imageUrl,
          'source': widget.article.source,
          'publishedAt': widget.article.publishedAt,
          'url': widget.article.url,
          'bookmarkedAt': DateTime.now().toIso8601String(),
        });
        setState(() {
          _isBookmarked = true;
          _isLoadingBookmark = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked 
                  ? 'Article bookmarked' 
                  : 'Bookmark removed',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingBookmark = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareArticle() async {
    try {
      await Share.share(
        '${widget.article.title}\n\n${widget.article.url}',
        subject: widget.article.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share article'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openInBrowser() async {
    final url = widget.article.url;
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open article'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      final month = months[date.month - 1];
      final day = date.day;
      final year = date.year;
      final hour = date.hour > 12 ? date.hour - 12 : date.hour;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      
      return '$month $day, $year • $hour:$minute $period';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.article.imageUrl != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 60,
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.article,
                        color: Colors.grey,
                        size: 60,
                      ),
                    ),
            ),
            actions: [
              // Bookmark button
              _isLoadingBookmark
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: _toggleBookmark,
                    ),
              
              // Share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _shareArticle,
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.article.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            letterSpacing: -0.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Source and Date
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.source,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.article.source,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Published date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(widget.article.publishedAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Description
                        if (widget.article.description != null &&
                            widget.article.description!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Text(
                              widget.article.description!,
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.grey[800],
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Content
                        if (widget.article.content != null &&
                            widget.article.content!.isNotEmpty)
                          Text(
                            widget.article.content!
                                .replaceAll(RegExp(r'\[\+\d+ chars\]'), ''),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                              height: 1.8,
                              letterSpacing: 0.2,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Full article content not available. Click below to read the complete article.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Read Full Article Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _openInBrowser,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text(
                              'Read Full Article',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action buttons row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _shareArticle,
                                icon: const Icon(Icons.share),
                                label: const Text('Share'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _toggleBookmark,
                                icon: Icon(
                                  _isBookmarked 
                                      ? Icons.bookmark 
                                      : Icons.bookmark_border,
                                ),
                                label: Text(
                                  _isBookmarked ? 'Saved' : 'Save',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  foregroundColor: _isBookmarked 
                                      ? Colors.blue 
                                      : null,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}