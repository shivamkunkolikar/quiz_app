import 'package:flutter/material.dart';
import 'package:quiz_app/answertest_page.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/login_page.dart';
import 'package:quiz_app/result_page.dart';
import 'package:quiz_app/testadmin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


  void _navigateToCreatedTestDetail(Map<String, dynamic> test) async{

    curr_quiz = await fetchQuizFromFirestore(test['ref'].id) as Quiz;

    if(curr_quiz.isComplete == false) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTestPage(flag: true),
        ),
      );
    }
    else {
      isActive = curr_quiz.isActive;
      await getResultsInDescendingOrder(curr_quiz.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestadminPage(testId: test['ref'].id.toString()),
        ),
      );
    }
  }

  void _navigateToAnsweredTestDetail(Map<String, dynamic> test) async{
    print('test 1 passed');
    curr_quiz = await fetchQuizFromFirestore(test['ref'].id) as Quiz;
    print('test 2 passed');
    await fetchUserAnswers(username);
    print('test 3 passed');

   
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResultPage(),
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
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('U',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: const BoxDecoration(color: Color(0xFF0094FF)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
              autofocus: true,
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
              onTap: () async{
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                await prefs.remove('email');
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 30, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Answered Tests', style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              )),
              answeredTests.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: Text('No Tests Answered')),      
                    )
                  : Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 30),
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: answeredTests.length,
                        itemBuilder: (context, index) {
                          int reverseIndex = answeredTests.length - 1 - index;
        
                          return Card(
                              color: const Color.fromRGBO(179, 223, 255, 1),
                              child: InkWell(
                                onTap: () => _navigateToAnsweredTestDetail(answeredTests[reverseIndex]),
                                child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 140,
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(2, 2, 2, 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.transparent),
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white
                                        ),
                                        child: const Icon(Icons.text_snippet_outlined, size: 100, color: Color.fromRGBO(128, 202, 255, 1),),
                                      ),
        
                                      Text(answeredTests[reverseIndex]['name'], style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                            );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              const Text('Created Tests', style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              )),
              createdTests.isEmpty
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: Text('No Tests Created')),      
                    )
                  : Container(
                      margin: const EdgeInsets.fromLTRB(0 , 5, 0, 0),
                      height: 200,
                      child: ListView.builder(
                        
                        scrollDirection: Axis.horizontal,
                        itemCount: createdTests.length,
                        itemBuilder: (context, index) {
                          int reverseIndex = createdTests.length - 1 - index;
        
                          return Card(
                              color: const Color.fromRGBO(179, 223, 255, 1),
                              child: InkWell(
                                onTap: () => _navigateToCreatedTestDetail(createdTests[reverseIndex]),
                                child: Container(
                                  width: 150,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 140,
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(2, 2, 2, 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.transparent),
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white
                                        ),
                                        child: const Icon(Icons.text_snippet, size: 100, color: Color.fromRGBO(128, 202, 255, 1),),
                                      ),
        
                                      Text(createdTests[reverseIndex]['name'], style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),),
                                    ],
                                  ),
                                ),
                              ),
                            );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateOrAnswerTest,
        backgroundColor: const Color(0xFF0094FF),
        child: const Icon(Icons.add, color: Colors.white,),
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
        
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.grey,
                      blurRadius: 5.0,
                    )
                  ]
                ),
                child: Material(
                  color: const Color(0xFF0094FF),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    
                    onTap: () async{
                      final db = FirebaseFirestore.instance;
                      curr_quiz = Quiz('', '', [], -1, username);
                      DocumentReference doc = await db.collection("tests").add(curr_quiz.toMap());
                      curr_quiz.id = doc.id;
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTestPage(flag: false)));
                    },
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      child: const Text('Create Test', style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),)
                    ),
                  ),
                ),
              ),

              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      color: Colors.grey,
                      blurRadius: 5.0,
                    )
                  ]
                ),
                margin: const EdgeInsets.all(10),
                child: Material(
                  color: const Color(0xFF09E21F),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    
                    onTap: () async{
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerTestPage()));
                    },
                    child: Container(
                      height: 50,
                      margin: const EdgeInsets.all(1),
                      alignment: Alignment.center,
                      child: const Text('Answer Test', style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),)
                    ),
                  ),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}


// Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerTestPage()));

