import 'package:flutter/material.dart';
import 'package:flutter_app_task/data/Tasks.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';

class NewTagInput extends StatefulWidget{
  NewTagInput({
    Key key
}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _NewTagInputState();
  }
}

class _NewTagInputState extends State<NewTagInput> {
  static const Color DEFAULT_COLOR = Colors.red;

  Color pickedTagColor = DEFAULT_COLOR;
  TextEditingController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          _buildTextField(context),
          _buildColorPickerButton(context)
        ],
      ),
    );
  }

  Flexible _buildTextField(BuildContext context) {
    return Flexible(
      flex: 1,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Tag Name"
        ),
        onSubmitted: (inputName){
          print("tag insert");
          final dao = Provider.of<AppDatabase>(context, listen: false).tagDao;
          final tag = Tag(
            name: inputName,
            color: pickedTagColor.value
          );
          dao.insertTag(tag);
          resetValuesAfterSubmit();
        },
      ),
    );
  }

  Widget _buildColorPickerButton(BuildContext context){
    return Flexible(
      flex: 1,
      child: GestureDetector(
        child: Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pickedTagColor
          ),
        ),
        onTap: (){
          _showColorPickerDialog(context);
        },
      ),
    );
  }

  void resetValuesAfterSubmit() {
    setState(() {
      pickedTagColor = DEFAULT_COLOR;
      controller.clear();
    });
  }

  Future _showColorPickerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: MaterialColorPicker(
            allowShades: false,
            selectedColor: DEFAULT_COLOR,
            onMainColorChange: (colorSwatch){
              setState(() {
                pickedTagColor = colorSwatch;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      }
    );
  }
}