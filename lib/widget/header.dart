import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hackathon/view_model/user_status.dart';
import '../view/login_page.dart';

class Header extends ConsumerWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user_status = ref.watch(userStatusViewModelProvider.notifier);
    final isLoggedIn = ref.watch(userStatusViewModelProvider).isLoggedIn;

    return AppBar(
      title: Center(
        child: Text(
          '石橋商店街カレンダー',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.person, size: 26, color: Colors.black),
          ),
          onPressed: () {
            if (isLoggedIn == true) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'ログイン中',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('すでにログインしています'),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('閉じる'),
                          ),
                          TextButton(
                            onPressed: () {
                              user_status.updateLoginStatus(false);
                              Navigator.pop(context);
                            },
                            child: const Text('ログアウト'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          },
        ),
      ],
    );
  }
}
