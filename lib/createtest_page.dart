import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/home_page.dart';
import 'package:flutter/foundation.dart';

int totalCorrectMarks = 0;

class QuizInputPage extends StatefulWidget {
  @override
  _QuizInputPageState createState() => _QuizInputPageState();
}

class _QuizInputPageState extends State<QuizInputPage> {
  List<Question> allQuestions = curr_quiz.que; 
  final _formKey = GlobalKey<FormState>();
  

  final TextEditingController questionTextController = TextEditingController();
  List<TextEditingController> optionControllers = List.generate(4, (_) => TextEditingController());
  final TextEditingController correctMarksController = TextEditingController(text: '0');
  final TextEditingController incorrectMarksController = TextEditingController(text: '0');
  final TextEditingController unattemptedMarksController = TextEditingController(text: '0');
  
  List<bool> isCorrect = [false, false, false, false];
  bool isMultipleCorrect = false; 
  int currentQuestionIndex = 0; 


  void _addOrUpdateQuestion() {
    if (_formKey.currentState!.validate()) {
      if (isCorrect.contains(true)) {
        _formKey.currentState!.save();

        List<String> options = optionControllers.map((controller) => controller.text).toList();
        List<int> marks = [
          int.parse(correctMarksController.text),
          int.parse(incorrectMarksController.text),
          int.parse(unattemptedMarksController.text),
        ];

    
        Question newQuestion = Question(
          questionTextController.text,
          options,
          marks,
          List.from(isCorrect),
          isMultipleCorrect,
        );

        setState(() {
          if (currentQuestionIndex < allQuestions.length) {
            totalCorrectMarks = totalCorrectMarks - marks[0];
            allQuestions[currentQuestionIndex] = newQuestion;
            totalCorrectMarks += marks[0];
          } else {
            allQuestions.add(newQuestion);
            totalCorrectMarks += marks[0]; 
          }

          _resetForm(); 

        
          if (currentQuestionIndex < allQuestions.length - 1) {
            _loadQuestion(currentQuestionIndex + 1);
          } else {
            currentQuestionIndex++; 
          }
        });

        print('Question added or updated: ${newQuestion.text}');
        print('Total Correct Marks: $totalCorrectMarks');
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one correct answer.')),
        );
      }
    }
  }

  
  void _resetForm() {
    _formKey.currentState!.reset(); 
    questionTextController.clear();
    for (var controller in optionControllers) {
      controller.clear();
    }
    isCorrect = [false, false, false, false];
  }

  
  void _finishQuestions() {
    print('All questions added or updated:');
    for (var question in allQuestions) {
      print(question);
    }
    print('Total Correct Marks: $totalCorrectMarks');
    curr_quiz.que = allQuestions;
    saveQuizToFirestore(curr_quiz);
    Navigator.pop(context);
  }

  
  void _loadQuestion(int index) {
    if (index >= 0 && index < allQuestions.length) {
      setState(() {
        currentQuestionIndex = index;
        Question question = allQuestions[index];
        questionTextController.text = question.text;
        for (int i = 0; i < 4; i++) {
          optionControllers[i].text = question.opt[i];
        }
        correctMarksController.text = question.mks[0].toString();
        incorrectMarksController.text = question.mks[1].toString();
        unattemptedMarksController.text = question.mks[2].toString();
        isCorrect = List.from(question.isCorrect);
        isMultipleCorrect = question.isMultipleCorrect;
      });
    }
  }

  
  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      _loadQuestion(currentQuestionIndex - 1);
    }
  }

  
  void _nextQuestion() {
    if (currentQuestionIndex < allQuestions.length - 1) {
      _loadQuestion(currentQuestionIndex + 1);
    } else {
      _resetForm(); 
    }
  }

  @override
  Widget build(BuildContext context) {

    _loadQuestion(currentQuestionIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${currentQuestionIndex + 1}', 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: questionTextController,
                  decoration: const InputDecoration(
                    labelText: 'Question Text',
                    border: OutlineInputBorder(), 
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the question text';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Multiple Correct'),
                    Switch(
                      value: isMultipleCorrect,
                      onChanged: (value) {
                        setState(() {
                          isMultipleCorrect = value;
                          if (!isMultipleCorrect) {
                            
                            isCorrect = [false, false, false, false];
                          }
                        });
                      },
                    ),
                  ],
                ),
                ...List.generate(4, (index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: optionControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Option ${index + 1}',
                                border: const OutlineInputBorder(), 
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter option ${index + 1}';
                                }
                                return null;
                              },
                            ),
                          ),
                          Checkbox(
                            value: isCorrect[index],
                            onChanged: (value) {
                              setState(() {
                                if (isMultipleCorrect) {
                                  isCorrect[index] = value!;
                                } else {
                                  if (value == true) {
                                    isCorrect = [false, false, false, false];
                                    isCorrect[index] = true;
                                  } else {
                                    isCorrect[index] = false;
                                  }
                                }
                              });
                            },
                          ),
                          
                        ],
                      ),
                      const SizedBox(height: 10), 
                    ],
                  );
                }),
                const SizedBox(height: 20),
                TextFormField(
                  controller: correctMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks for Correct Answer',
                    border: OutlineInputBorder(), 
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter marks for correct answer';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: incorrectMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks for Incorrect Answer',
                    border: OutlineInputBorder(), 
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter marks for incorrect answer';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: unattemptedMarksController,
                  decoration: const InputDecoration(
                    labelText: 'Marks for Unattempted Question',
                    border: OutlineInputBorder(), 
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter marks for unattempted question';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB904), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                      ),
                      child: const Text('Prev'),
                    ),
                    ElevatedButton(
                      onPressed: _addOrUpdateQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B99FF), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                      ),
                      child: const Text('Add / Update'),
                    ),
                    ElevatedButton(
                      onPressed: currentQuestionIndex < allQuestions.length - 1 ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0DDC30), 
                        foregroundColor: Colors.white, 
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                        shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _finishQuestions,
                    style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0DDC30), 
                          foregroundColor: Colors.white, 
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                          ),
                    ),
                    child: const Text('Finish Entering Questions'),
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







































void setNewQuiz() async{
    final db = FirebaseFirestore.instance;
    curr_quiz = Quiz('', '', [], -1, username);
    DocumentReference doc = await db.collection("tests").add(curr_quiz.toMap());
    curr_quiz.id = doc.id;
    print(curr_quiz.id);
}





String _testcode = ''; 



class CreateTestPage extends StatefulWidget {
  CreateTestPage({super.key, required this.flag, this.ind = -1});
  final flag;
  int ind = -1;

  @override
  _CreateTestPageState createState() => _CreateTestPageState(flag, ind);
}

class _CreateTestPageState extends State<CreateTestPage> {
  _CreateTestPageState(this.flag, this.ind);
  bool flag;
  int ind;

  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testDurationController = TextEditingController();

  bool mapExistsInList(Map<String, dynamic> map, List<dynamic> mapList) {
    for (var element in mapList) {
      if (mapEquals(element, map)) {
        return true;
      }
      else if(element['ref'] == map['ref']) {
        element['name'] = map['name'];
        return true;
      }
    }
    return false;
  }

  void _addQuestions() {
    print("Add Questions button pressed");

    Navigator.push(context, MaterialPageRoute(builder: (context) => QuizInputPage()));

  }

  void _saveQuiz() async{

    print("Save Questions button pressed");


    await saveQuizToFirestore(curr_quiz);
    final db = FirebaseFirestore.instance;
    DocumentReference docRef = db.collection('tests').doc(curr_quiz.id);
    if(mapExistsInList({'ref': docRef, 'name': curr_quiz.name}, createdTests) == false) {
      createdTests.add({'ref': docRef, 'name': curr_quiz.name});
      await updateCreatedTestList(createdTests);
    }
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  void _createTest() async{
    // Logic to create the test
    curr_quiz.isComplete = true;
    await saveQuizToFirestore(curr_quiz);
    final db = FirebaseFirestore.instance;
    DocumentReference docRef = db.collection('tests').doc(curr_quiz.id);
    if(!mapExistsInList({'ref': docRef, 'name': curr_quiz.name}, createdTests)) {
      createdTests.add({'ref': docRef, 'name': curr_quiz.name});
    }
    await updateCreatedTestList(createdTests);
    user_dash.noCreatedtests = user_dash.noCreatedtests + 1;
    await storeDashboardData(user_dash);
    print("Create Test button pressed");
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }


  

  

  @override
  Widget build(BuildContext context) {

    if(curr_quiz.name != '') {
      _testNameController.text = curr_quiz.name;
    }

    if(curr_quiz.time != -1) {
      _testDurationController.text = curr_quiz.time.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Test Code : ${curr_quiz.id}', // Placeholder for test code
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Material(
                    color: Colors.transparent,
                    
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async{
                        await Clipboard.setData(ClipboardData(text: curr_quiz.id));
                      },
                      child: const SizedBox(
                        child: Center(
                          child: Icon(Icons.copy)
                        ),
                      ),
                    ),
                  ),
                        
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _testNameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Test Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  curr_quiz.name = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _testDurationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter Test Duration',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  curr_quiz.time = int.parse(value);
                },
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Test duration should be in minutes',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _addQuestions,
                icon: const Icon(Icons.add),
                label: const Text('Add Questions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _saveQuiz,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _createTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0DDC30), 
                  foregroundColor: Colors.white, 
                  minimumSize: const Size(double.infinity, 50), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), 
                  ),
                ),
                child: const Text('Create Test', style: TextStyle(
                  fontWeight: FontWeight.w600,
                )),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Once test is created questions cannot be edited',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
