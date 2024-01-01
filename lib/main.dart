import 'package:flutter/material.dart';

void main() {
  runApp(ToDoApp());
}

class Task {
  String title;
  DateTime dueDate;
  TaskPriority priority;
  bool isDone;

  Task({
    required this.title,
    required this.dueDate,
    required this.priority,
    this.isDone = false,
  });
}

enum TaskPriority { High, Medium, Low }

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO app',
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<Task> tasks = [];

  void addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void toggleDone(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY DAY'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(tasks[index].title),
            onDismissed: (direction) {
              removeTask(index);
            },
            child: ListTile(
              title: Text(
                tasks[index].title,
                style: tasks[index].isDone
                    ? TextStyle(decoration: TextDecoration.lineThrough)
                    : null,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: <Widget>[
                      Text('Priority: '),
                      Chip(
                        label: Text(
                          tasks[index].priority.toString().split('.').last,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor:
                            _getPriorityColor(tasks[index].priority),
                      ),
                    ],
                  ),
                  Text(
                    'Due Date: ${tasks[index].dueDate.toString()}',
                    style: tasks[index].isDone
                        ? TextStyle(decoration: TextDecoration.lineThrough)
                        : null,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: tasks[index].isDone
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : Icon(Icons.radio_button_unchecked,
                            color: Colors.blue),
                    onPressed: () {
                      toggleDone(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.blue),
                    onPressed: () {
                      removeTask(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a dialog to add a task with details
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTaskDialog(addTask: addTask);
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.High:
        return Colors.red;
      case TaskPriority.Medium:
        return Colors.yellow;
      case TaskPriority.Low:
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  final Function(Task) addTask;

  const AddTaskDialog({Key? key, required this.addTask}) : super(key: key);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late String _title;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _title = '';
    _dueDate = DateTime.now();
    _dueTime = TimeOfDay.now();
    _priority = TaskPriority.Low;
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: TaskPriority.values.map((priority) {
              return ListTile(
                title: Text(priority.toString().split('.').last),
                onTap: () {
                  setState(() {
                    _priority = priority;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Title'),
            onChanged: (value) {
              _title = value;
            },
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Text('Priority:'),
              SizedBox(width: 10),
              Chip(
                label: Text(
                  _priority.toString().split('.').last,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getPriorityColor(_priority),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _showPriorityDialog();
                },
                child: Text('Change'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Due Date:'),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null && pickedDate != _dueDate) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Due Time:'),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _dueTime,
                  );
                  if (pickedTime != null && pickedTime != _dueTime) {
                    setState(() {
                      _dueTime = pickedTime;
                    });
                  }
                },
                child: Text('Select Time'),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Add'),
          onPressed: () {
            final dueDateTime = DateTime(
              _dueDate.year,
              _dueDate.month,
              _dueDate.day,
              _dueTime.hour,
              _dueTime.minute,
            );

            widget.addTask(Task(
              title: _title,
              dueDate: dueDateTime,
              priority: _priority,
            ));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.High:
        return Colors.red;
      case TaskPriority.Medium:
        return Colors.yellow;
      case TaskPriority.Low:
        return Colors.green;
      default:
        return Colors.green;
    }
  }
}
