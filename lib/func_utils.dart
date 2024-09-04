//import 'package:quiz_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';

String username = '';
String password = "";
String email = '';
List<dynamic> createdTests = [];
List<dynamic> answeredTests = [];

class Question {
  Question(this.text, this.opt, this.mks, this.isCorrect, this.isMultipleCorrect);

  String text;
  List<String> opt;
  List<int> mks;
  List<bool> isCorrect;
  List<bool> userAns = [false, false, false, false];
  bool isMultipleCorrect;

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'opt': opt,
      'mks': mks,
      'isCorrect': isCorrect,
      'isMultipleCorrect': isMultipleCorrect,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      map['text'] as String,
      List<String>.from(map['opt']),
      List<int>.from(map['mks']),
      List<bool>.from(map['isCorrect']),
      map['isMultipleCorrect'] as bool,
    );
  }
}

class Quiz {
  Quiz(this.id, this.name, this.que, this.time, {this.isActive = false, this.isComplete = false});

  String id;
  String name;
  List<Question> que;
  int time;
  bool isActive = false;
  bool isComplete = false;
  List<int> ans_arr = [];

  Question at_loc(int index) {
    return que[index - 1];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'que': que.map((q) => q.toMap()).toList(),
      'time': time,
      'isActive': isActive,
      'isComplete': isComplete
    };
  }

  factory Quiz.fromMap(String id, Map<String, dynamic> map) {
    return Quiz(
      id,
      map['name'] as String,
      (map['que'] as List<dynamic>).map((q) => Question.fromMap(q as Map<String, dynamic>)).toList(),
      map['time'] as int,
      isActive: map['isActive'],
      isComplete: map['isComplete']
    );
  }
}

Future<void> saveQuizToFirestore(Quiz quiz) async {

  CollectionReference testsCollection = FirebaseFirestore.instance.collection('tests');

  Map<String, dynamic> quizData = quiz.toMap();

  try {
    await testsCollection.doc(quiz.id).set(quizData);
    print('Quiz saved successfully!');
  } catch (e) {
    print('Failed to save quiz: $e');
  }
}

Future<Quiz?> fetchQuizFromFirestore(String documentId) async {
  try {

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('tests').doc(documentId).get();

    if (docSnapshot.exists) {
      
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      Quiz quiz = Quiz.fromMap(docSnapshot.id, data);
      print('Quiz fetched successfully!');
      return quiz;

    } else {
      
      print('Quiz with ID $documentId does not exist.');
      return null;

    }
  } catch (e) {
    print('Failed to fetch quiz: $e');
    return null;
  }
}


Future<void> updateCreatedTestList(List<dynamic> newList) async {
  try {
    
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(username);
    
    await userDocRef.update({
      'createdTests': newList,
    });

    print('List updated successfully in Firestore.');
  } catch (e) {
    print('Error updating list: $e');
  }
}