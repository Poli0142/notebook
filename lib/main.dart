import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const NotesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Note> notes = [];
  final TextEditingController _textController = TextEditingController();
  int? _editingIndex;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _saveNote() {
    String text = _textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Напишите что-нибудь!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_editingIndex == null) {
        notes.add(
          Note(
            text: text,
            dateTime: DateTime.now(),
          ),
        );
      } else {
        notes[_editingIndex!] = Note(
          text: text,
          dateTime: DateTime.now(),
        );
        _editingIndex = null;
      }
    });

    _textController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingIndex == null ? 'Заметка добавлена!' : 'Заметка обновлена!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _editNote(int index) {
    setState(() {
      _editingIndex = index;
      _textController.text = notes[index].text;
    });
  }

  void _deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      if (_editingIndex == index) {
        _editingIndex = null;
        _textController.clear();
      } else if (_editingIndex != null && _editingIndex! > index) {
        _editingIndex = _editingIndex! - 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Заметка удалена'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заметки'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Введите заметку...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: Text(_editingIndex == null ? 'Добавить' : 'Сохранить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? const Center(
                    child: Text(
                      'Пока нет заметок',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(note.text),
                          subtitle: Text(
                            '${note.dateTime.day}.'
                            '${note.dateTime.month}.'
                            '${note.dateTime.year} '
                            '${note.dateTime.hour.toString().padLeft(2, '0')}:'
                            '${note.dateTime.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editNote(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNote(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Note {
  final String text;
  final DateTime dateTime;

  Note({required this.text, required this.dateTime});
}