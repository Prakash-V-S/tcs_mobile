import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/token_storage.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showAvatar;
  final bool showBackIcon;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAvatar = true,
    this.showBackIcon = false,
    this.onBackPressed,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String? _profileLogoBase64;
  bool _isLoadingAvatar = true;

  @override
  void initState() {
    super.initState();
    _loadProfileLogo();
  }

  Future<void> _loadProfileLogo() async {
    // In a production app you could also inject this via Provider, but directly resolving
    // from SharedPreferences works perfectly for a global constant that doesn't change post-login.
    try {
      final tokenStorage = TokenStorageImpl();
      final logo = await tokenStorage.getProfileLogo();
      if (mounted) {
        setState(() {
          _profileLogoBase64 = logo;
          _isLoadingAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: widget.showBackIcon
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : (widget.showAvatar
              ? IconButton(
                  icon: _buildAvatar(),
                  onPressed: () {
                    // Open sliding Drawer or Profile settings
                  },
                )
              : null),
      actions:
          widget.actions ??
          [
            IconButton(
              icon: const Icon(Icons.bookmark_border, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushNamed('/subscriptions');
              },
            ),

            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
    );
  }

  Widget _buildAvatar() {
    if (_isLoadingAvatar) {
      return CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: const SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      backgroundImage:
          _profileLogoBase64 != null && _profileLogoBase64!.isNotEmpty
          ? MemoryImage(
                  base64Decode(
                    _profileLogoBase64!.replaceFirst(
                      RegExp(r'data:image/[^;]+;base64,'),
                      '',
                    ),
                  ),
                )
                as ImageProvider
          : const AssetImage('assets/images/avatars/defaultprofile.png'),
    );
  }
}
