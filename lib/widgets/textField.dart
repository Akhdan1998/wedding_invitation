part of '../pages.dart';

class TextFieldCustom extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final bool icon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double height;
  final double borderRadius;
  final Color fillColor;
  final BorderSide borderSide;
  final bool filled;
  final TextCapitalization textCapitalization;

  const TextFieldCustom({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.icon = false,
    this.controller,
    this.focusNode,
    required this.height,
    this.borderRadius = 10.0,
    this.fillColor = Colors.white,
    this.borderSide = BorderSide.none,
    this.filled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<TextFieldCustom> createState() => _TextFieldCustomState();
}

class _TextFieldCustomState extends State<TextFieldCustom> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: TextFormField(
        style: Desk(),
        textCapitalization: widget.textCapitalization,
        focusNode: widget.focusNode,
        keyboardType: TextInputType.emailAddress,
        obscureText: _obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          filled: widget.filled,
          fillColor: widget.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: widget.borderSide,
          ),
          hintText: widget.hintText,
          hintStyle: Desk(color: Colors.black38),
          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              size: 20,
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}