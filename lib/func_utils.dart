//import 'package:quiz_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Map<String, dynamic> toAnswerMap() {
    return {
      'userAns': userAns
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

  bool checkifUnattemted() {
    for(int i=0 ; i<4 ; i++) {
      if(userAns[i] == true) return false;
    }
    return true;
  }

  double evalQuestion() {
    if(isMultipleCorrect == false) {
      if(listEquals(isCorrect, userAns)) {
        return 0.0 + mks[0];
      }
      else if(checkifUnattemted()) {
         return 0.0 + mks[2];
      }
      else {
        return 0.0 + mks[1];
      }
    }
    else {
      if(checkifUnattemted()) {
        return mks[2] + 0.0; 
      }
      else if(listEquals(isCorrect, userAns)) {
        return mks[1] + 0.0;
      }
      else {
        int cnt = 0;
        for(int i=0 ; i<4 ; i++) {
          if(isCorrect[i] == true) {
            cnt = cnt + 1;
          }
        }

        double atomMarks = mks[0] / cnt; 
        double tot_marks = 0.0; 
        for(int i=0 ; i<4  ; i++) {
          if(isCorrect[i] == false && userAns[i] == true) {
            return mks[1] + 0.0;
          }
          else if(isCorrect[i] == true && userAns[i] == true) {
            tot_marks = tot_marks + atomMarks;
          }
        }
        return tot_marks;
      }
    }
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

   Map<String, dynamic> toAnswerMap() {
    return {
      'username': username,
      'marks': evaluateTest(),
      'ans': que.map((q) => q.toAnswerMap()).toList(),
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

  int calcTotal() {
    int ret = 0;
    for(int i=0 ; i<que.length ; i++) {
      ret = ret + que[i].mks[0];
    }
    return ret;
  }

  double evaluateTest() {
    int len = que.length;
    double marks = 0.0;

    for(int i=0 ; i<len ; i++) {
      marks = marks + que[i].evalQuestion();
      print(' ${i+1}  ${marks}  ${que[i].evalQuestion()}');
    }

    return marks;

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

Future<void> updateAnsweredTestList(List<dynamic> newList) async {
  try {
    
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(username);
    
    await userDocRef.update({
      'answeredTests': newList,
    });

    print('List updated successfully in Firestore.');
  } catch (e) {
    print('Error updating list: $e');
  }
}


Future<void> saveResultToFirestore(Quiz quiz) async {

  CollectionReference testsCollection = FirebaseFirestore.instance.collection('tests').doc(quiz.id).collection('results');

  Map<String, dynamic> quizData = quiz.toAnswerMap();

  try {
    await testsCollection.doc(username).set(quizData);
    print('Result saved successfully!');
  } catch (e) {
    print('Failed to save quiz: $e');
  }
}

