import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/home_page.dart';
import 'package:flutter/foundation.dart';




// Global variable to store total marks for correct answers of all questions
int totalCorrectMarks = 0;

// class Question {
//   Question(this.text, this.opt, this.mks, this.isCorrect, this.isMultipleCorrect);

//   String text; // Question text
//   List<String> opt; // List of options (4 options)
//   List<int> mks; // Marks: [correct marks, incorrect marks, unattempted marks]
//   List<bool> isCorrect; // List of booleans to indicate which options are correct
//   bool isMultipleCorrect; // Toggle state for allowing multiple correct answers

//   @override
//   String toString() {
//     return 'Question{text: $text, opt: $opt, mks: $mks, isCorrect: $isCorrect, isMultipleCorrect: $isMultipleCorrect}';
//   }
// }


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
            // Update existing question
            totalCorrectMarks = totalCorrectMarks - marks[0];
            allQuestions[currentQuestionIndex] = newQuestion;
            totalCorrectMarks += marks[0];
          } else {
            // Add new question
            allQuestions.add(newQuestion);
            totalCorrectMarks += marks[0]; // Update the total marks for correct answers
          }

          _resetForm(); // Reset form after adding or updating question

          // Move to the next question or prepare a new form for input
          if (currentQuestionIndex < allQuestions.length - 1) {
            _loadQuestion(currentQuestionIndex + 1);
          } else {
            currentQuestionIndex++; // Move to a new question index
          }
        });

        print('Question added or updated: ${newQuestion.text}');
        print('Total Correct Marks: $totalCorrectMarks');
      } else {
        // Show error message if no correct option is selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one correct answer.')),
        );
      }
    }
  }

  // Method to reset the form after a question is added or updated
  void _resetForm() {
    _formKey.currentState!.reset(); // Reset the form fields
    questionTextController.clear();
    for (var controller in optionControllers) {
      controller.clear();
    }
    isCorrect = [false, false, false, false];
  }

  // Method to finalize input and print all questions
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

  // Method to load a question for editing
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

  // Method to navigate to the previous question
  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      _loadQuestion(currentQuestionIndex - 1);
    }
  }

  // Method to navigate to the next question
  void _nextQuestion() {
    if (currentQuestionIndex < allQuestions.length - 1) {
      _loadQuestion(currentQuestionIndex + 1);
    } else {
      _resetForm(); // Clear form for new question input
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
                  'Question ${currentQuestionIndex + 1}', // Display the current question number
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: questionTextController,
                  decoration: InputDecoration(
                    labelText: 'Question Text',
                    border: OutlineInputBorder(), // Rectangular border
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the question text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Multiple Correct'),
                    Switch(
                      value: isMultipleCorrect,
                      onChanged: (value) {
                        setState(() {
                          isMultipleCorrect = value;
                          if (!isMultipleCorrect) {
                            // Reset all isCorrect values to false if multiple correct is off
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
                                border: OutlineInputBorder(), // Rectangular border
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
                          //Text('Correct'),
                        ],
                      ),
                      SizedBox(height: 10), // Add space between option inputs
                    ],
                  );
                }),
                SizedBox(height: 20),
                TextFormField(
                  controller: correctMarksController,
                  decoration: InputDecoration(
                    labelText: 'Marks for Correct Answer',
                    border: OutlineInputBorder(), // Rectangular border
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
                SizedBox(height: 20),
                TextFormField(
                  controller: incorrectMarksController,
                  decoration: InputDecoration(
                    labelText: 'Marks for Incorrect Answer',
                    border: OutlineInputBorder(), // Rectangular border
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
                SizedBox(height: 20),
                TextFormField(
                  controller: unattemptedMarksController,
                  decoration: InputDecoration(
                    labelText: 'Marks for Unattempted Question',
                    border: OutlineInputBorder(), // Rectangular border
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
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: currentQuestionIndex > 0 ? _previousQuestion : null,
                      child: Text('Previous'),
                    ),
                    ElevatedButton(
                      onPressed: _addOrUpdateQuestion,
                      child: Text('Add/Update Question'),
                    ),
                    ElevatedButton(
                      onPressed: currentQuestionIndex < allQuestions.length - 1 ? _nextQuestion : null,
                      child: Text('Next'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _finishQuestions,
                  child: Text('Finish Entering Questions'),
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
    curr_quiz = Quiz('', '', [], -1);
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
    print("Create Test button pressed");
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  // void getData(ind) async{
  //   final db = FirebaseFirestore.instance;
  //   final quizMap = await createdTests[ind].get().data();
  //   if(quizMap['isComplete']) {}
  //   else {
  //     curr_quiz = Quiz.fromMap(quizMap['id'], quizMap);
  //   }
  // }

  

  

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Test Code : ${curr_quiz.id}', // Placeholder for test code
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                minimumSize: const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Reduced border radius
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _saveQuiz,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button color
                foregroundColor: Colors.white, // Text color
                minimumSize: const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Reduced border radius
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _createTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                foregroundColor: Colors.white, // Text color
                minimumSize: const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Reduced border radius
                ),
              ),
              child: const Text('Create Test'),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Once test is created questions cannot be edited',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
