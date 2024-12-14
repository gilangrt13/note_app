import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://a.supabase.co', 
    anonKey: ''
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ), 
      home: NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final response = await supabase.from('notes').select();
    setState(() {
      notes = response;
    });
  }

  Future<void> addNote() async {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Note'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter your note'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await supabase.from('notes').insert({
                  'content': controller.text,
                });
                fetchNotes();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> editNote(int id, String currentContent) async {
    final TextEditingController controller = TextEditingController(text: currentContent);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Note'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Update your note'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await supabase.from('notes').update({
                  'content': controller.text,
                }).eq('id', id);
                fetchNotes();
                Navigator.pop(context);
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteNote(int id) async {
    await supabase.from('notes').delete().eq('id', id);
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['content']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => editNote(note['id'], note['content']),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => deleteNote(note['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}

