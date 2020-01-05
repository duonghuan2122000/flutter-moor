import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_task/data/Tasks.dart';
import 'package:flutter_app_task/ui/widget/new_tag_input_widget.dart';
import 'package:flutter_app_task/ui/widget/new_task_input_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{
  bool showCompleted = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        actions: <Widget>[
          _buildCompletedOnlySwitch()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _buildTaskList(context),
          ),
          NewTaskInput(),
          NewTagInput()
        ],
      ),
    );
  }

  Row _buildCompletedOnlySwitch(){
    return Row(
      children: <Widget>[
        Text("Completed only"),
        Switch(
          value: showCompleted,
          activeColor: Colors.white,
          onChanged: (newValue){
            setState(() {
              showCompleted = newValue;
            });
          },
        )
      ],
    );
  }

  StreamBuilder<List<TaskWithTag>> _buildTaskList(BuildContext context){
    final dao = Provider.of<AppDatabase>(context).taskDao;
    return StreamBuilder(
      stream: showCompleted ? dao.watchCompletedTasks() : dao.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<TaskWithTag>> snapshot){
        final tasks = snapshot.data ?? List();

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index){
            final itemTask = tasks[index];
            return _buildListItem(itemTask, dao);
          },
        );
      },
    );
  }

  Widget _buildListItem(TaskWithTag itemTask, TaskDao dao){
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: "Delete",
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => dao.deleteTask(itemTask.task),
        )
      ],
      child: CheckboxListTile(
        title: Text(itemTask.task.name),
        subtitle: Text(itemTask.task.dueDate?.toString() ?? "No date"),
        secondary: _buildTag(itemTask.tag),
        value: itemTask.task.completed,
        onChanged: (newValue){
          dao.updateTask(itemTask.task.copyWith(completed: newValue));
        },
      ),
    );
  }
  
  Column _buildTag(Tag tag){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if(tag != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(tag.color)
            ),
          ),
          Text(
            tag.name,
            style: TextStyle(
              color: Colors.black.withOpacity(0.5)
            ),
          )
        ]
      ],
    );
  }
}
