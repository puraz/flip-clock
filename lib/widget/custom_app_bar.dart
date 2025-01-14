import 'package:flutter/cupertino.dart';

import 'head_title.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return HeadTitle();
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
