import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Center(
        child: Text('石橋商店街カレンダー', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

