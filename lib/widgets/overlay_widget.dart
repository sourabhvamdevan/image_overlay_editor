import 'package:flutter/material.dart';
import '../models/overlay_item.dart';

class OverlayWidget extends StatefulWidget {
  final OverlayItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEditText;

  const OverlayWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.onEditText,
  });

  @override
  State<OverlayWidget> createState() => _OverlayWidgetState();
}

class _OverlayWidgetState extends State<OverlayWidget> {
  double _startScale = 1.0;
  double _startRotation = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.item.position.dx,
      top: widget.item.position.dy,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.item.type == OverlayType.text
            ? widget.onEditText
            : null,
        onScaleStart: (details) {
          _startScale = widget.item.scale;
          _startRotation = widget.item.rotation;
        },
        onScaleUpdate: (details) {
          setState(() {
            widget.item.scale = _startScale * details.scale;
            widget.item.rotation = _startRotation + details.rotation;
            widget.item.position += details.focalPointDelta;
          });
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(widget.item.scale)
            ..rotateZ(widget.item.rotation),
          child: Container(
            decoration: widget.isSelected
                ? BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.item.type == OverlayType.image) {
      return Image.asset(widget.item.data, width: 100);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
      child: Text(
        widget.item.data,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
