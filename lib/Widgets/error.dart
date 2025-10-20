import 'package:flutter/material.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorWidgetCustom({
    Key? key,
    this.title = 'Oops! Something went wrong',
    this.message = 'Unable to load content. Please check your connection.',
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Specialized error widgets for common scenarios
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorWidgetCustom(
      title: 'No Internet Connection',
      message: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

class ApiErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ApiErrorWidget({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorWidgetCustom(
      title: 'Failed to Load News',
      message: 'We couldn\'t fetch the latest news. Please try again.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }
}