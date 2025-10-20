import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // final UserRepository _userRepository = UserRepository();
  
  String _username = 'JohnDoe'; // Replace with actual logged in user
  List<String> _selectedCategories = ['general', 'technology']; // Default
  
  final List<String> _availableCategories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    // TODO: Load from database
    // final user = await _userRepository.getUser(_username);
    // if (user != null) {
    //   setState(() {
    //     _selectedCategories = user.favoriteCategories;
    //   });
    // }
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: CategorySelectorSheet(
            categories: _availableCategories,
            selectedCategories: _selectedCategories,
            onSave: (selected) {
              setState(() {
                _selectedCategories = selected;
              });
              // TODO: Save to database
              // _userRepository.updateFavoriteCategories(...)
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categories updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'News Aggregator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text(
              'A modern news aggregator app built with Flutter. Stay updated with the latest news from various categories.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear user session
              Navigator.pop(context); // Close dialog
              // Navigate to login screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // User Profile Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedCategories.length} categories selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Preferences Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.category,
            title: 'Favorite Categories',
            subtitle: _selectedCategories.join(', '),
            onTap: _showCategorySelector,
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.language,
            title: 'Country',
            trailingText: 'United States',
            onTap: () {
              // TODO: Implement country selector
            },
          ),

          const SizedBox(height: 16),

          // App Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'App',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.notifications,
            title: 'Notifications',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notifications toggle
              },
            ),
            onTap: null,
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement dark mode
              },
            ),
            onTap: null,
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.info_outline,
            title: 'About',
            onTap: _showAboutDialog,
          ),

          const SizedBox(height: 16),

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.red,
            onTap: _handleLogout,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// Category Selector Sheet Widget
class CategorySelectorSheet extends StatefulWidget {
  final List<String> categories;
  final List<String> selectedCategories;
  final Function(List<String>) onSave;

  const CategorySelectorSheet({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.onSave,
  }) : super(key: key);

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  late List<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedCategories);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_tempSelected.contains(category)) {
        _tempSelected.remove(category);
      } else {
        _tempSelected.add(category);
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'business':
        return Icons.business;
      case 'sports':
        return Icons.sports_soccer;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'science':
        return Icons.science;
      case 'general':
        return Icons.public;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Select Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_tempSelected.length} selected',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Category Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = _tempSelected.contains(category);

              return InkWell(
                onTap: () => _toggleCategory(category),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              color: isSelected ? Colors.white : Colors.grey[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category[0].toUpperCase() + category.substring(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.blue,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Save button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _tempSelected.isEmpty
                  ? null
                  : () => widget.onSave(_tempSelected),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Preferences',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Settings List Tile Widget (inline since we need it here)
class SettingsListTileWidget extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsListTileWidget({
    Key? key,
    required this.leadingIcon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.trailing,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            leadingIcon,
            color: iconColor ?? Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: trailing ??
            (trailingText != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trailingText!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  )
                : Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  )),
      ),
    );
  }
}