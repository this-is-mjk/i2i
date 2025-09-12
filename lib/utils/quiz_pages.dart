import 'package:flutter/material.dart';
import 'package:i2i/utils/objects/questions.dart';
import 'package:i2i/utils/quiz_page.dart';
import 'package:i2i/screens/quiz_results.dart';

class QuizPages extends StatefulWidget {
  final List<Question> questions;
  const QuizPages({super.key, required this.questions});

  @override
  State<QuizPages> createState() => _QuizPagesState();
}

class _QuizPagesState extends State<QuizPages> with TickerProviderStateMixin {
  late PageController _pageViewController;
  late TabController _tabController;
  int _currentPageIndex = 0;
  late int questionCount = widget.questions.length;

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
    _tabController = TabController(length: questionCount, vsync: this);

    // Listen to tab changes (dot taps)
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _updateCurrentPageIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        PageView(
          controller: _pageViewController,
          onPageChanged: _handlePageViewChanged,
          children:
              widget.questions.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                return QuizPage(
                  currentPageIndex: _currentPageIndex,
                  index: index,
                  question: question,
                  isLast: _currentPageIndex == questionCount - 1,
                  onNext: () {
                    if (_currentPageIndex < questionCount - 1) {
                      _updateCurrentPageIndex(_currentPageIndex + 1);
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ResultPage(
                                questions: widget.questions,
                                test: true,
                              ),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
        ),

        // Always show PageIndicator
        PageIndicator(
          tabController: _tabController,
          currentPageIndex: _currentPageIndex,
          onUpdateCurrentPageIndex: _updateCurrentPageIndex,
        ),
      ],
    );
  }

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  void _updateCurrentPageIndex(int index) {
    _tabController.index = index;
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPageIndex = index;
    });
  }
}

/// Page indicator for desktop and web platforms.
///
/// On Desktop and Web, drag gesture for horizontal scrolling in a PageView is disabled by default.
/// You can defined a custom scroll behavior to activate drag gestures,
/// see https://docs.flutter.dev/release/breaking-changes/default-scroll-behavior-drag.
///
/// In this sample, we use a TabPageSelector to navigate between pages,
/// in order to build natural behavior similar to other desktop applications.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.tabController,
    required this.currentPageIndex,
    required this.onUpdateCurrentPageIndex,
  });

  final int currentPageIndex;
  final TabController tabController;
  final void Function(int) onUpdateCurrentPageIndex;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // IconButton(
            //   splashRadius: 16.0,
            //   padding: EdgeInsets.zero,
            //   onPressed:
            //       currentPageIndex > 0
            //           ? () => onUpdateCurrentPageIndex(currentPageIndex - 1)
            //           : null,
            //   icon: const Icon(Icons.arrow_left_rounded, size: 32.0),
            // ),
            TabPageSelector(
              controller: tabController,
              color: colorScheme.surface,
              selectedColor: colorScheme.primary,
            ),
            // IconButton(
            //   splashRadius: 16.0,
            //   padding: EdgeInsets.zero,
            //   onPressed:
            //       currentPageIndex < tabController.length - 1
            //           ? () => onUpdateCurrentPageIndex(currentPageIndex + 1)
            //           : null,
            //   icon: const Icon(Icons.arrow_right_rounded, size: 32.0),
            // ),
          ],
        ),
      ),
    );
  }
}
