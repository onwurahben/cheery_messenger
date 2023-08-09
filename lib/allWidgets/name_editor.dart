import 'package:flutter/material.dart';

class FieldEditor extends StatefulWidget {

  final TextEditingController? controller;
  String value;
  final ValueChanged<String> onSaveValue;
  String valueType;

  FieldEditor({super.key, required this.controller, required this.value, required this.onSaveValue, required this.valueType });

  @override
  State<FieldEditor> createState() => _FieldEditorState();
}

class _FieldEditorState extends State<FieldEditor> {
  late TextEditingController valueController;
  String? newValue ;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
     valueController = widget.controller!;
     newValue = widget.value;

    print('yo $newValue');

  }

  void _saveName() {
    setState(() {
      newValue = valueController.text;
      _editing = false;

      print('ho $newValue');
    });

    widget.onSaveValue(newValue!);
  }

  Widget _buildEditingName() {
    return Container(
      height: 80,
      width: 312,
      decoration: const BoxDecoration(
        color: Color(0xFF323538),
        borderRadius: BorderRadius.all(Radius.circular(20)),),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: widget.valueType),
              onChanged: (value) {
                newValue = value;
              },
             ),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveName,
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayingName() {
    return Container(
      height: 40,
      width: 312,
      constraints: const BoxConstraints(
        maxHeight: 200,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF323538),
        borderRadius: BorderRadius.all(Radius.circular(20)),),
      child: Row(
        children: [
          Expanded(
            child: Text(
              newValue ?? widget.valueType,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            color: const Color(0xFF7958D1),
            onPressed: () {
              setState(() {
                _editing = true;
                valueController.text = newValue ?? '';

                print('ya $newValue');
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _editing ? _buildEditingName() : _buildDisplayingName();
  }
}

