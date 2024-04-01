import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Lista de Tareas',
      home: ToDoList(),
    );
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _textFieldController = TextEditingController();
  List<String> todos = [];
  late DatabaseHelper _databaseHelper;

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final List<String> retrievedTodos = await _databaseHelper.retrieveTodos();
    setState(() {
      todos = retrievedTodos;
    });
  }

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
            onDismissed: (direction) async {
              if (direction == DismissDirection.endToStart) {
                await _databaseHelper.deleteTodo(index + 1);
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
        onPressed: _addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addTodo() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTodo = '';
        return AlertDialog(
          title: const Text('Agrega una nueva Tarea'),
          content: TextField(
            controller: _textFieldController,
            onChanged: (value) {
              newTodo = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Agregar'),
              onPressed: () async {
                await _databaseHelper.insertTodo(newTodo);
                _fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _modifyTodo(int index) async {
    final TextEditingController _updateFieldController =
        TextEditingController(text: todos[index]);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String updatedTodo = todos[index];
        return AlertDialog(
          title: const Text('Modificar Tarea'),
          content: TextField(
            controller: _updateFieldController,
            onChanged: (value) {
              updatedTodo = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                await _databaseHelper.updateTodo(index + 1, updatedTodo);
                _fetchTodos();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class DatabaseHelper {
  static late Database _database;
  static const String tableName = 'todos';

  Future<Database> get database async {
    _database = await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, 'todo_database.db');
    return await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, todo TEXT)",
        );
      },
    );
  }

  Future<void> insertTodo(String todo) async {
    final Database db = await database;
    await db.insert(
      tableName,
      {'todo': todo},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> retrieveTodos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return maps[i]['todo'];
    });
  }

  Future<void> updateTodo(int id, String todo) async {
    final Database db = await database;
    await db.update(
      tableName,
      {'todo': todo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTodo(int id) async {
    final Database db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
