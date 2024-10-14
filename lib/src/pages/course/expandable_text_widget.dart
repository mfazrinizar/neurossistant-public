import 'package:flutter/material.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String titleText;
  final String bodyText;
  final String? spacingText;
  final TextStyle? spacingStyle;
  final TextStyle? bodyStyle;
  final TextStyle? titleStyle;
  final Duration animationDuration;
  final String showLess;
  final String showMore;

  const ExpandableTextWidget({
    Key? key,
    required this.titleText,
    required this.bodyText,
    this.spacingText,
    this.spacingStyle,
    this.bodyStyle,
    this.titleStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.showLess = 'Show less',
    this.showMore = 'Show more',
  }) : super(key: key);

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: widget.animationDuration,
            curve: Curves.easeInOut,
            child: Column(children: [
              Text(
                widget.titleText,
                style: widget.titleStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.fade,
                maxLines: _isExpanded ? null : 1,
              ),
              Container(
                height: 2.0,
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              if (widget.spacingText != null && _isExpanded)
                Text(
                  widget.spacingText!,
                  style: widget.spacingStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.fade,
                  maxLines: _isExpanded ? null : 1,
                ),
              Text(
                widget.bodyText,
                style: widget.bodyStyle,
                overflow: TextOverflow.fade,
                maxLines: _isExpanded ? null : 2,
              ),
            ]),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: Row(
              children: [
                Text(
                  _isExpanded ? widget.showLess : widget.showMore,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
