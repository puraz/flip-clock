import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flip Clock'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: Colors.pink,
          child: Column(
            children: [
                Flexible(
                    child: Container(
                        color: Colors.orange,
                        child: Center(
                            child: Text('body'),
                        ),
                    ),
                ),
                Container(
                    color: Colors.yellow,
                    child: SizedBox(
                        height: 40,
                        child: Center(
                            child: Text('bottom'),
                        ),
                    ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}