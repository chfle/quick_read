import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetailWidget extends StatelessWidget {
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String source;
  final String publishedAt;
  final String articleUrl;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onShare;

  const ArticleDetailWidget({
    Key? key,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.articleUrl,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    this.onShare,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMMM d, yyyy • h:mm a').format(date);
    } catch (e) {
      return '';
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey, size: 60),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.article,
                          color: Colors.grey, size: 60),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: onBookmarkToggle,
              ),
              if (onShare != null)
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: onShare,
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

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
                        child: Text(
                          source,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _formatDate(publishedAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (description != null && description!.isNotEmpty) ...[
                    Text(
                      description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Content
                  if (content != null && content!.isNotEmpty) ...[
                    Text(
                      content!,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[800],
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Read Full Article Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(articleUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text(
                        'Read Full Article',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}