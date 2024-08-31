import 'package:flutter/material.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:quiz_app/main.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<String> answeredTests = [];
  // List<String> createdTests = [];

  void _navigateToCreateOrAnswerTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrAnswerTestPage(
          onTestCreated: _addCreatedTest,
          onTestAnswered: _addAnsweredTest,
        ),
      ),
    );
  }

  void _addCreatedTest(String test) {
    setState(() {
      createdTests.add(test);
    });
  }

  void _addAnsweredTest(String test) {
    setState(() {
      answeredTests.add(test);
    });
  }

  void _navigateToTestDetail(String test) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestDetailPage(test: test),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('User Name'),
              accountEmail: Text('user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('U',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(color: Color(0xFF0094FF)),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                // Handle sign out
              },
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Answered Tests', style: TextStyle(fontSize: 18)),
            answeredTests.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(child: Text('No Tests Answered')),      
                  )
                : Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: answeredTests.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToTestDetail(answeredTests[index]),
                          child: Card(
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(answeredTests[index])),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 20),
            const Text('Created Tests', style: TextStyle(fontSize: 18)),
            createdTests.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(child: Text('No Tests Created')),      
                  )
                : Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: createdTests.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _navigateToTestDetail(createdTests[index]),
                          child: Card(
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(createdTests[index])),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOrAnswerTest,
        child: const Icon(Icons.add),
      ),

    );
  }
}

class CreateOrAnswerTestPage extends StatelessWidget {
  final Function(String) onTestCreated;
  final Function(String) onTestAnswered;

  CreateOrAnswerTestPage({ required this.onTestCreated, required this.onTestAnswered});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create or Answer Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async{
                final db = FirebaseFirestore.instance;
                curr_quiz = Quiz('', '', [], -1);
                DocumentReference doc = await db.collection("tests").add(curr_quiz.toMap());
                curr_quiz.id = doc.id;
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTestPage(flag: false)));
              },
              child: const Text('Create Test'),
            ),
            ElevatedButton(
              onPressed: () {
                onTestAnswered('Test ${DateTime.now()}');
                Navigator.pop(context);
                //Navigator.push(context, MaterialPageRoute(builder: (context) => EnterTestCodeWidget()));
              },
              child: const Text('Answer Test'),
            ),
          ],
        ),
      ),
    );
  }
}

class TestDetailPage extends StatelessWidget {
  final String test;

  TestDetailPage({required this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Detail'),
      ),
      body: Center(
        child: Text(test, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
