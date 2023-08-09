

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'allWidgets/name_editor.dart';

Widget fieldEditing(

    String tag,

    final TextEditingController? controller,
    String value,
    final ValueChanged<String> onSaveValue,
    String valueType,

    ){

  return
    Container(
      decoration: BoxDecoration(
          color: const Color(0xFF323538),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 8, right: 8),
      child: Column(

        mainAxisAlignment: MainAxisAlignment.start,
        children: [

           Align(
              alignment: Alignment.centerLeft,
              child: Text(tag, style: const TextStyle(color: Colors.white),)
          ),

          const Divider(color: Colors.white,),

          FieldEditor(
            controller: controller,
            value: value,
            onSaveValue: onSaveValue,
            valueType: valueType,

          ),
        ],
      ),
    );

}