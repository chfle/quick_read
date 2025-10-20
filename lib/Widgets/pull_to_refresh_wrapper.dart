import 'package:flutter/material.dart';

class PullToRefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;

  const PullToRefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      child: child,
    );
  }
}