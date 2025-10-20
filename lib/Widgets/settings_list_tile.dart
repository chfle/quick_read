import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsListTile({
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
      color: Colors.grey[50],
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