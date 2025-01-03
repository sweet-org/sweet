import 'package:flutter/material.dart';

class SweetSearchBar extends StatefulWidget {
  final void Function(String) onSubmit;
  final String? labelText;
  final int minOnChangedLength;
  final bool triggerOnChange;

  SweetSearchBar({
    Key? key,
    required this.onSubmit,
    this.labelText,
    this.minOnChangedLength = 3,
    this.triggerOnChange = false,
  }) : super(key: key);

  @override
  State<SweetSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SweetSearchBar> {
  final textEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyLarge!.color!.withAlpha(128);
    return SizedBox.fromSize(
      size: Size.fromHeight(48),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Theme.of(context).canvasColor,
            ),
            child: TextField(
              controller: textEditController,
              onChanged: (filterString) {
                if (filterString.isEmpty ||
                    filterString.length >= widget.minOnChangedLength) {
                  widget.onSubmit(filterString);
                }
              },
              onSubmitted: (filterString) {
                textEditController.text = filterString;
                widget.onSubmit(filterString);
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: color,
                ),
                suffixIcon: IconButton(
                  padding: EdgeInsets.zero,
                  color: color,
                  iconSize: 20,
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    textEditController.clear();
                    widget.onSubmit('');
                  },
                ),
                labelText: widget.labelText ?? 'Search for something...',
                labelStyle: TextStyle(
                  color: color,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
