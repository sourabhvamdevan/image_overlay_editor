import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../models/overlay_item.dart';
import '../widgets/overlay_widget.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<OverlayItem> _items = [];
  OverlayItem? _selectedItem;
  int _idCounter = 0;
  bool _isDark = false;

  void _addLogo() {
    setState(() {
      _items.add(
        OverlayItem(
          id: 'item_${_idCounter++}',
          type: OverlayType.image,
          data: 'assets/logo.png',
          position: const Offset(100, 100),
          zIndex: _items.length,
        ),
      );
    });
  }

  void _addText() {
    setState(() {
      _items.add(
        OverlayItem(
          id: 'item_${_idCounter++}',
          type: OverlayType.text,
          data: 'Double tap to edit',
          position: const Offset(120, 220),
          zIndex: _items.length,
        ),
      );
    });
  }

  void _deleteSelected() {
    if (_selectedItem == null) return;
    setState(() {
      _items.remove(_selectedItem);
      _selectedItem = null;
    });
  }

  void _editTextDialog(OverlayItem item) {
    final controller = TextEditingController(text: item.data);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Text'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => item.data = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportImage() async {
    final boundary =
        _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(byteData!.buffer.asUint8List());

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    _items.sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overlay Editor'),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDark = !_isDark),
          ),
          if (_selectedItem != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelected,
            ),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportImage),
        ],
      ),
      body: Theme(
        data: _isDark
            ? Theme.of(context).copyWith(brightness: Brightness.dark)
            : Theme.of(context).copyWith(brightness: Brightness.light),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedItem = null),
                child: Center(
                  child: RepaintBoundary(
                    key: _canvasKey,
                    child: Stack(
                      children: [
                        Image.asset('assets/sample.jpg'),
                        ..._items.map(
                          (item) => OverlayWidget(
                            item: item,
                            isSelected: item == _selectedItem,
                            onTap: () {
                              setState(() {
                                _selectedItem = item;
                                item.zIndex = _items.length;
                              });
                            },
                            onEditText: () => _editTextDialog(item),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addLogo,
                  child: const Text('Add Logo'),
                ),
                ElevatedButton(
                  onPressed: _addText,
                  child: const Text('Add Text'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
