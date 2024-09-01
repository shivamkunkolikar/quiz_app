import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:quiz_app/func_utils.dart';
import 'dart:async';


class AnswerTestPage extends StatefulWidget {
  @override
  _AnswerTestPageState createState() => _AnswerTestPageState();
}

class _AnswerTestPageState extends State<AnswerTestPage> {
  final TextEditingController _testCodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _fetchTestData() async {
    final String testCode = _testCodeController.text.trim();
    if (testCode.isEmpty) {
      _showErrorMessage('Please enter a test code.');
      return;
    }

    try {
      DocumentSnapshot doc = await _firestore.collection('tests').doc(testCode).get();

      if (doc.exists) {
        // Assuming you have a method to parse the data into a Quiz object
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        curr_quiz = Quiz.fromMap(doc.id, data);
        print('Quiz retrieved: ${curr_quiz.name}');
        // Navigate to the quiz page or handle quiz data
         Navigator.push(context, MaterialPageRoute(builder: (context) => QuizPage()));


      } else {
        _showErrorMessage('The test code entered does not exist.');
      }
    } catch (e) {
      _showErrorMessage('An error occurred while fetching the test data.');
      print(e);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answer Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _testCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Test Code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Enter valid test code given by the test creator',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchTestData,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.arrow_forward, color: Colors.white,),
      ),
    );
  }
}





























































class FullScreenDrawer extends StatelessWidget {
  FullScreenDrawer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text('Back'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // Adjust the number of columns as needed
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                padding: EdgeInsets.all(10.0),
                itemCount: curr_quiz.que.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print('Tapped on index $index');
                    },
                    child: CircleAvatar(
                      radius: 5,
                      child: Text('${index + 1}'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Submit button pressed');
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Timer? _timer;
  int curr_q = 1;
  int time_left = curr_quiz.time - 1; // Start from given time in minutes
  int time_left_sec = 59; // Start seconds from 59
  Question _newQuestion = curr_quiz.at_loc(1);

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (time_left == 0 && time_left_sec == 0) {
        _timer!.cancel();
        // Time is up, handle the end of the quiz
      } else {
        setState(() {
          if (time_left_sec == 0) {
            if (time_left > 0) {
              time_left--;
              time_left_sec = 59;
            }
          } else {
            time_left_sec--;
          }
        });
      }
    });
  }

  void _getQuestion(int index) {
    if (index > curr_quiz.que.length) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitPage()));
    } else if (index < 1) {
      // Do nothing
    } else {
      curr_q = index;
      setState(() {
        _newQuestion = curr_quiz.at_loc(index);
      });
    }
  }

  void _getNext() {
    setState(() {
      curr_q++;
      _newQuestion = curr_quiz.at_loc(curr_q);
    });
  }

  int curr_ind = -1;
  void _setCurrInd(int curr, int index) {
    setState(() {
      curr_quiz.ans_arr[curr] = index+1;
    });
  }

  dynamic retBgCol(int curr, int index) {
    return index == curr_quiz.ans_arr[curr]-1 ? Colors.white : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF007A), Color(0xFFFF3939)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Time Left: $time_left:$time_left_sec mins'),
        ),
        drawer: Container(
      width: MediaQuery.of(context).size.width,
      child: Drawer(
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.arrow_back),
              title: Text('Back'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, // Adjust the number of columns as needed
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                padding: EdgeInsets.all(10.0),
                itemCount: curr_quiz.que.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _getQuestion(index+1);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      radius: 5,
                      child: Text('${index + 1}'),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Submit button pressed');
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    ),
        // SizedBox(
        //   width: MediaQuery.of(context).size.width, // Full screen width
        //   child: Drawer(
        //     child: ListView(
        //       padding: EdgeInsets.zero,
        //       children: [
        //         const DrawerHeader(
        //           decoration: BoxDecoration(
        //             color: Colors.blue,
        //           ),
        //           child: Text(
        //             'Drawer Header',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontSize: 24,
        //             ),
        //           ),
        //         ),
        //         ListTile(
        //           leading: Icon(Icons.info),
        //           title: Text('About'),
        //           onTap: () {
        //             Navigator.pop(context);
        //             // Navigate to about screen or any other action
        //           },
        //         ),
        //         // Container(
        //         //   child: GridView.count(crossAxisCount: 5,
        //         //     children: [],
        //         //   ),
        //         //),
        //       ],
        //     ),
        //   ),
        // ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(255, 255, 255, 0.75),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(onPressed: () {
                curr_quiz.ans_arr[curr_q] = 0;
              }, child: const Text('Clear')),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _getQuestion(curr_q - 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 145, 0, 1),
                    ),
                    child: const Text('Prev'),
                  ),
                  ElevatedButton(
                    onPressed: () => _getQuestion(curr_q + 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(6, 189, 0, 1),
                    ),
                    child: const Text('Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: double.infinity,
                height: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  children: [
                    // Question Container
                    Container(
                      height: 120,
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromRGBO(255, 255, 255, 0.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Question $curr_q:',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            _newQuestion.text,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Options Area
                    ListView.builder(
                      itemCount: _newQuestion.opt.length-1,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _setCurrInd(curr_q, index),
                          child: Container(
                            height: 50,
                            margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color.fromARGB(190, 255, 255, 255)),
                              borderRadius: BorderRadius.circular(12),
                              color: retBgCol(curr_q, index),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 10,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(_newQuestion.opt[index]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}



class SubmitPage extends StatelessWidget {
  const SubmitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.5),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Container(
              child: Column(
                children: [
                  const Text('Do You Want To Submit Test ? '),
                  const ElevatedButton(onPressed: null, child: Text('Submit Test')),
                  ElevatedButton(onPressed: () { Navigator.pop(context); }, child: const Text('Go Back')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

