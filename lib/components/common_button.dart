import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final bool isOutlined;
  final TextStyle? textStyle;

  const CommonButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width = double.infinity,
    this.isOutlined = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: Colors.white,
    );

    return Center(
      child: SizedBox(
        width: width,
        child:
            isOutlined
                ? OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    // padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  child: Text(text, style: textStyle),
                )
                : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      // Bottom shadow
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .55),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                      // Top shadow
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .3),
                        blurRadius: 10,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0, // using custom shadows instead
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    ),
                    child: Text(text, style: textStyle),
                  ),
                ),
      ),
    );
  }
}
