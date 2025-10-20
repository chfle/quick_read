import 'package:flutter/material.dart';

class BookmarkButtonWidget extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onToggle;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showSnackbar;

  const BookmarkButtonWidget({
    Key? key,
    required this.isBookmarked,
    required this.onToggle,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.showSnackbar = true,
  }) : super(key: key);

  @override
  State<BookmarkButtonWidget> createState() => _BookmarkButtonWidgetState();
}

class _BookmarkButtonWidgetState extends State<BookmarkButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Animate
    _controller.forward().then((_) {
      _controller.reverse();
    });

    // Call toggle callback
    widget.onToggle();

    // Show snackbar
    if (widget.showSnackbar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isBookmarked
                ? 'Removed from bookmarks'
                : 'Added to bookmarks',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: widget.isBookmarked
              ? (widget.activeColor ?? Colors.blue)
              : (widget.inactiveColor ?? Colors.grey[600]),
        ),
        onPressed: _handleTap,
        iconSize: widget.size,
      ),
    );
  }
}