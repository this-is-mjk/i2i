import 'package:flutter/material.dart';
import 'package:i2i/utils/common_button.dart';

class InstructionsScreen extends StatelessWidget {
  final String title;
  final String instructions;
  final VoidCallback onStart;

  const InstructionsScreen({
    super.key,
    required this.title,
    required this.instructions,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    instructions,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CommonButton(onPressed: onStart, text: 'Start'),
            ],
          ),
        ),
      ),
    );
  }
}
