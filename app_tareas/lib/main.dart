import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lista de Tareas',
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<String> todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(todos[index]),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmación'),
                      content:
                          const Text('¿Estás seguro de eliminar esta tarea?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                _modifyTodo(index);
                return false;
              }
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                setState(() {
                  todos.removeAt(index);
                });
              }
            },
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20.0),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 204, 255, 206),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                title: Text(todos[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTodo();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodo = '';
        return AlertDialog(
          title: const Text('Agrega una nueva Tarea'),
          content: TextField(
            onChanged: (value) {
              newTodo = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Agregar'),
              onPressed: () {
                setState(() {
                  todos.add(newTodo);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _modifyTodo(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedTodo = todos[index];
        return AlertDialog(
          title: const Text('Modificar Tarea'),
          content: TextField(
            controller: TextEditingController(text: updatedTodo),
            onChanged: (value) {
              updatedTodo = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                setState(() {
                  todos[index] = updatedTodo;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
