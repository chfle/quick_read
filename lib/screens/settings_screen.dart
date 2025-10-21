import 'package:flutter/material.dart';
import '../repository/user_repository.dart';
import '../services/news_api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserRepository _userRepository = UserRepository();
  
  String _username = 'User'; // Will be loaded from session
  int? _userId;
  List<String> _selectedCategories = ['general', 'technology'];
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedCountry = 'us';
  bool _isLoading = false;
  
  final List<String> _availableCategories = NewsApiService.availableCategories;
  
  final Map<String, String> _availableCountries = {
    'us': 'United States',
    'gb': 'United Kingdom',
    'ca': 'Canada',
    'au': 'Australia',
    'de': 'Germany',
  };

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For now, we'll use a hardcoded username since we don't have session management
      // In a real app, you'd get this from shared preferences or a session manager
      const tempUsername = 'testuser';
      
      final user = await _userRepository.getUser(tempUsername);
      if (user != null) {
        setState(() {
          _username = user.username;
          _userId = user.id;
          _selectedCategories = user.favoriteCategories;
        });
      } else {
        // Create a default user if none exists
        await _userRepository.registerUser(
          username: tempUsername,
          password: 'password123',
          favoriteCategories: ['general', 'technology'],
        );
        setState(() {
          _username = tempUsername;
          _selectedCategories = ['general', 'technology'];
        });
      }
    } catch (e) {
      print('Error loading user settings: $e');
      // Use defaults if loading fails
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCategories(List<String> categories) async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userRepository.updateFavoriteCategories(
        userId: _userId!,
        categories: categories,
      );
      
      setState(() {
        _selectedCategories = categories;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categories updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            onSave: (selected) async {
              Navigator.pop(context);
              await _saveCategories(selected);
            },
          ),
        ),
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Country',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._availableCountries.entries.map((entry) {
              final isSelected = _selectedCountry == entry.key;
              return ListTile(
                title: Text(entry.value),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  setState(() {
                    _selectedCountry = entry.key;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Country changed to ${entry.value}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            }).toList(),
          ],
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
              Navigator.pop(context); // Close dialog
              
              // Clear any session data here (like SharedPreferences)
              // In a real app, you'd clear tokens, user data, etc.
              
              // Navigate to login screen and clear the navigation stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            trailingText: _availableCountries[_selectedCountry] ?? 'United States',
            onTap: _showCountrySelector,
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
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            onTap: null,
          ),

          SettingsListTileWidget(
            leadingIcon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
                    backgroundColor: Colors.green,
                  ),
                );
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