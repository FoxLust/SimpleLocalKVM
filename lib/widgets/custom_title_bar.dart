import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isTransparent;
  final VoidCallback? onBackPressed;

  const CustomTitleBar({
    super.key,
    required this.title,
    this.isTransparent = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: isTransparent ? Colors.transparent : Colors.deepPurple.shade900,
      child: Row(
        children: [
          // Back Button (if provided)
          if (onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
              onPressed: onBackPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40),
            ),

          // Title & Drag Area
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                windowManager.startDragging();
              },
              onDoubleTap: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.restore();
                } else {
                  windowManager.maximize();
                }
              },
              child: Container(
                color: Colors.transparent, // Hit test for drag
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Window Controls
          _WindowButton(
            icon: Icons.minimize,
            onPressed: () => windowManager.minimize(),
          ),
          _WindowButton(
            icon: Icons.crop_square,
            onPressed: () async {
               if (await windowManager.isMaximized()) {
                  windowManager.restore();
                } else {
                  windowManager.maximize();
                }
            },
          ),
          _WindowButton(
            icon: Icons.close,
            color: Colors.red,
            hoverColor: Colors.red.shade700,
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(32);
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final Color? hoverColor;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.hoverColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      hoverColor: hoverColor ?? Colors.white.withOpacity(0.1),
      child: Container(
        width: 40,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: color ?? Colors.white),
      ),
    );
  }
}
