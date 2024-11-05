import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/home_page.dart';
import 'dart:async';

import 'package:quiz_app/result_page.dart';


class AnswerTestPage extends StatefulWidget {
  @override
  _AnswerTestPageState createState() => _AnswerTestPageState();
}

class _AnswerTestPageState extends State<AnswerTestPage> {

    bool mapExistsInList(dynamic docRef, List<dynamic> mapList) {
    for (var element in mapList) {
      if(docRef == element['ref']) return true;
    }
    return false;
  }
  
  final TextEditingController _testCodeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _fetchTestData() async {
    final String testCode = _testCodeController.text.trim();
    if (testCode.isEmpty) {
      _showErrorMessage('Please enter a test code.');
      return;
    }

    try {
      DocumentReference docRef = FirebaseFirestore.instance.collection('tests').doc(testCode);
      DocumentSnapshot doc = await _firestore.collection('tests').doc(testCode).get();

      if (doc.exists) {

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        curr_quiz = Quiz.fromMap(doc.id, data);
        print('Quiz retrieved: ${curr_quiz.name}');

        if(curr_quiz.isActive == false) {
          _showErrorMessage('The test is Currently Inactive');
        }
        else if(mapExistsInList(docRef, answeredTests)) {
          _showErrorMessage('Test Already Answered');
        }
        else if(curr_quiz.isComplete == false) {
          _showErrorMessage('The test code entered does not exist.');
        }
        else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const TestHeadingPage(title: 'H',)));
        }

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
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back'),
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
                padding: const EdgeInsets.all(10.0),
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
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Future<void> submitTestFunction() async{ 
  final db = FirebaseFirestore.instance;
  await saveResultToFirestore(curr_quiz);
  DocumentReference docRef = db.collection('tests').doc(curr_quiz.id);
  answeredTests.add({'ref': docRef, 'name': curr_quiz.name});
  user_dash.addToStats(curr_quiz.evalStats());
  user_dash.noAnsweredtests = answeredTests.length;
  await updateAnsweredTestList(answeredTests);
  await storeDashboardData(user_dash);
  await updateHomeInfo();
                      
}


class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Timer? _timer;
  int curr_q = 1;
  int time_left = curr_quiz.time - 1; 
  int time_left_sec = 59; 
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async{
      if (time_left == 0 && time_left_sec == 0) {
        _timer!.cancel();
        // Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  AutoSubmitPage()));
        await submitTestFunction();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  SuccessSubmitPage()));

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitTestPage()));
    } else if (index < 1) {
      // Do nothing
    } else {
      curr_q = index;
      curr_quiz.que[index-1].isVisited = true;
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
      if(curr_quiz.que[curr-1].isMultipleCorrect == true) {
        curr_quiz.que[curr-1].userAns[index] = curr_quiz.que[curr-1].userAns[index] ? false : true;
      }
      else {
        for(int i=0 ; i<4 ; i++) {
          curr_quiz.que[curr-1].userAns[i] = false;
        }
        curr_quiz.que[curr-1].userAns[index] = curr_quiz.que[curr-1].userAns[index] ? false : true;
      }
    });
  }

  void _clearAll() {
    setState(() {
        for(int i=0 ; i<4 ; i++) {
          curr_quiz.que[curr_q-1].userAns[i] = false;
        }
      }
    );
  }

  dynamic retBgCol(int curr, int index) {
    if (curr_quiz.que[curr-1].userAns[index] == true) {
      return Colors.white;
    }
    else {
      return Colors.transparent;
    }
  }

  dynamic retGridBg(int curr) {
    if(curr == 1) {
      if(curr_quiz.que[curr - 1].checkifUnattemted()){
        return Colors.red;
      }
      else {
        return Colors.green;
      }

    }
    else if(curr_quiz.que[curr - 1].isVisited == false) {
      return Colors.grey[350];
    }
    else {
      if(curr_quiz.que[curr - 1].checkifUnattemted()) {
        return Colors.red;
      }
      else {
        return Colors.green;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // colors: [Color(0xFFFF007A), Color(0xFFFF3939)],
          colors: [Color.fromARGB(255, 0, 148, 255), Color.fromARGB(255, 0, 148, 255)]
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
            const SizedBox(height: 30,),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back'),
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
                padding: const EdgeInsets.all(10.0),
                itemCount: curr_quiz.que.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _getQuestion(index+1);
                      curr_quiz.que[index].isVisited = true;
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: retGridBg(index + 1),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>  const SubmitTestPage()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0DDC30), 
                  foregroundColor: Colors.white, 
                  padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), 
                  ),
                ),
                child: const Text('Submit', style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),),
              ),
            ),
          ],
        ),
      ),
    ),
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(255, 255, 255, 0.75),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                 _clearAll();
                }, 
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent, 
                  foregroundColor: const Color(0xFF615F5F), 
                  // padding: const EdgeInsets.symmetric( horizontal: 30.0, vertical: 15.0),
                      
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                ),
                child: const Text('Clear')
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _getQuestion(curr_q - 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 145, 0, 1),
                      foregroundColor: Colors.white, 
                      // padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                    ),
                    
                    child: const Text('Prev'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      
                      _getQuestion(curr_q + 1);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(6, 189, 0, 1),
                      foregroundColor: Colors.white, 
                      // padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                // height: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Container
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Question $curr_q'),
                            content: SingleChildScrollView(
                              child: Text(_newQuestion.text),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
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
                                maxLines:
                                        2, // Limiting to 2 lines for short options
                                    overflow: TextOverflow
                                        .ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                ),
                              ),
                            
                          ],
                        ),
                      ),
                    ),

                    _newQuestion.isMultipleCorrect 
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      const Text('\n   Choose one or more options'),
                      Container(
                        width: 45,
                        height: 25,
                        margin: const EdgeInsets.fromLTRB(10, 12, 30, 0),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child:  Text('MSQ', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 11,
                          ),),
                        ),
                      ), 
                      ],)
                    : const Text('\n   Choose any one option'),

                    // Options Area
                    ListView.builder(
                      itemCount: _newQuestion.opt.length,
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
                                
                                // Flexible(child: Text(_newQuestion.opt[index], overflow: TextOverflow.ellipsis,)),
                                Expanded(
                                  child: Text(
                                    _newQuestion.opt[index],
                                    softWrap: true,
                                    maxLines:
                                        2, // Limiting to 2 lines for short options
                                    overflow: TextOverflow
                                        .ellipsis, // Add ellipsis for long text
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                
                              ),

                              

                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16,), // Eye icon
                                  onPressed: () {
                                  // This will show the modal for full text
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Full Option Text'),
                                          content: Text(_newQuestion.opt[index]),
                                          actions: [
                                            TextButton(
                                              child: const Text('Close'),
                                              onPressed: () {Navigator.of(context).pop();},
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                },
                              ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10, height: 60,),
                  ],
                ),
              ),



              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.done, color: Colors.green,),
                        Text(': ${_newQuestion.mks[0]}', style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.close, color: Colors.red,),
                        Text(': ${_newQuestion.mks[1]}', style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.format_underline_sharp, color: Colors.black,),
                        Text(': ${_newQuestion.mks[2]}', style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),),
                      ],
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





















































class TestHeadingPage extends StatefulWidget {
  const TestHeadingPage({super.key, required this.title});

  final String title;

  @override
  State<TestHeadingPage> createState() => _TestHeadingPageState();
}

class _TestHeadingPageState extends State<TestHeadingPage> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0094FF), Color(0xFF0094FF)]
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        // ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 60,
                color: Colors.transparent,
                margin: const EdgeInsets.symmetric(horizontal: 10),
          
              ),
              Container(
                // height: 500,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TestDiscription(),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage()));
                        
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0DDC30), 
                            foregroundColor: Colors.white, 
                            padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), 
                            ),
                          ),
                          child: const Text('Start Test', style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),), 
                        ),
                      ),
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
}

class TestDiscription extends StatelessWidget {
  const TestDiscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      margin: const EdgeInsets.fromLTRB(22, 30, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(curr_quiz.name, style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF00599A),
            fontWeight: FontWeight.w600,
          ),),
          Text('Test Duration : ${curr_quiz.time} minutes'),
          Text('Test Creator  : ${curr_quiz.userName}'),
          
        ],
      ),
    );
  }
}

class TestStartInterface extends StatelessWidget {
  const TestStartInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text('Download Animation'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage()));
            },
             
            child: const Text('Start Test'), 
          ),
        ],
      ),
    );
  }
}




























class SubmitTestPage extends StatefulWidget {
  const SubmitTestPage({super.key});

  @override
  State<SubmitTestPage> createState() => _SubmitTestPageState();
}



class _SubmitTestPageState extends State<SubmitTestPage> {
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, 
      body: Center(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          width: double.infinity, 
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6), 
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Do You want to Submit Test?',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4E4E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Text(
                'Total Questions       : ${curr_quiz.que.length}\n'
                'Attempted Questions   : ${curr_quiz.calcAttemted()}\n'
                'Unattempted Questions : ${curr_quiz.calcUnattemted()}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E4E4E),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      foregroundColor: const Color(0xFF4E4E4E), 
                      padding: const EdgeInsets.symmetric( horizontal: 30.0, vertical: 15.0),
                      
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                    ),
                    child: const Text('Go Back', style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: () async{
                      setState(() {
                        isLoading = true;
                      });
                      final db = FirebaseFirestore.instance;
                      await saveResultToFirestore(curr_quiz);
                      DocumentReference docRef = db.collection('tests').doc(curr_quiz.id);
                      answeredTests.add({'ref': docRef, 'name': curr_quiz.name});
                      user_dash.addToStats(curr_quiz.evalStats());
                      user_dash.noAnsweredtests = answeredTests.length;
                      await updateAnsweredTestList(answeredTests);
                      await storeDashboardData(user_dash);
                      await updateHomeInfo();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  SuccessSubmitPage()));
                      setState(() {
                        isLoading = false;
                      });
                      print("Test Submitted");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading == true ? const CircularProgressIndicator(color: Colors.white,) : const Text('Submit Test'),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class SuccessSubmitPage extends StatefulWidget {
  @override
  State<SuccessSubmitPage> createState() => _SuccessSubmitPageState();
}

class _SuccessSubmitPageState extends State<SuccessSubmitPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A1E4), // Light blue background color
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFFB3E5FC),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Test Submitted Successfully', style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E4E4E),
                ),),
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.done, color: Colors.green, size: 32,),
                ),
                Material(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                          },
                          child: const SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                  
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}
















class AutoSubmitPage extends StatefulWidget {
  @override
  State<AutoSubmitPage> createState() => _AutoSubmitPageState();
}

class _AutoSubmitPageState extends State<AutoSubmitPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A1E4), // Light blue background color
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: 420,
            decoration: BoxDecoration(
              color: const Color(0xFFB3E5FC),
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Submiting Test', style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E4E4E),
                ),),
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.done, color: Colors.green, size: 32,),
                ),
                Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                          },
                          child: const SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                "Please Wait",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                  
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}































































