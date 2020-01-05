import 'package:flutter/material.dart';
import 'package:flutter_app_task/data/Tasks.dart';
import 'package:provider/provider.dart';

class NewTaskInput extends StatefulWidget{
  NewTaskInput({
    Key key
}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _NewTaskInputState();
  }
}

class _NewTaskInputState extends State<NewTaskInput> {
  DateTime newTasDate;
  TextEditingController controller;
  Tag selectedTag;

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
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTextField(context),
          _buildTagSelector(context),
          _buildDateButton(context),
        ],
      ),
    );
  }

  Expanded _buildTextField(BuildContext context){
    return Expanded(
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: "Task Name"),
        onSubmitted: (inputName) async{
          print("Submit: " + inputName);
          final dao = Provider.of<AppDatabase>(context, listen: false).taskDao;
          final task = Task(
            name: inputName,
            dueDate: newTasDate,
            tagName: selectedTag?.name
          );
          dao.insertTask(task);
          resetValuesAfterSubmit();
        },
      ),
    );
  }

  StreamBuilder<List<Tag>> _buildTagSelector(BuildContext context){
    return StreamBuilder<List<Tag>>(
      stream: Provider.of<AppDatabase>(context).tagDao.watchTags(),
      builder: (context, snapshot){
        final tags = snapshot.data ?? List();

        DropdownMenuItem<Tag> dropdownMenuItem(Tag tag){
          return DropdownMenuItem(
            value: tag,
            child: Row(
              children: <Widget>[
                Text(tag.name),
                SizedBox(width: 5,),
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(tag.color)
                  ),
                )
              ],
            ),
          );
        }

        final dropdownMenuItems =
          tags.map((tag) => dropdownMenuItem(tag)).toList()
            ..insert(0, DropdownMenuItem(
              value: null,
              child: Text("No Tag"),
            ));

        return Expanded(
          child: DropdownButton(
            onChanged: (Tag tag){
              setState(() {
                selectedTag = tag;
              });
            },
            isExpanded: true,
            value: selectedTag,
            items: dropdownMenuItems,
          ),
        );
      },
    );
  }

  IconButton _buildDateButton(BuildContext context){
    return IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: () async{
        newTasDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050)
        );
      },
    );
  }

  void resetValuesAfterSubmit(){
    setState(() {
      newTasDate = null;
      controller.clear();
    });
  }
}