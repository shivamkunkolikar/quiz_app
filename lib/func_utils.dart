//import 'package:quiz_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

String username = '';
String password = "";
String email = '';
String name = '';
String phno = '';
String institute = '';
List<dynamic> createdTests = [];
List<dynamic> answeredTests = [];
List<dynamic> resultList = [];
// List<Result> resultList = [
//   Result(id: 'User 1', marks: 80, ans:[]),
//   Result(id: 'User 2', marks: 78, ans:[]),
//   Result(id: 'User 3', marks: 60, ans:[]),
//   Result(id: 'User 4', marks: 58, ans:[]),
// ];

Quiz curr_quiz = Quiz('', '', [], -1);

class Question {
  Question(this.text, this.opt, this.mks, this.isCorrect, this.isMultipleCorrect);

  String text;
  List<String> opt;
  List<int> mks;
  List<bool> isCorrect;
  List<bool> userAns = [false, false, false, false];
  bool isMultipleCorrect;
  bool isVisited = false;

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
        return mks[0] + 0.0;
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

  String returnStatus() {
    if(isMultipleCorrect == false) {
      if(listEquals(isCorrect, userAns)) {
        return 'Correct';
      }
      else if(checkifUnattemted()) {
        return 'Unattemted';
      }
      else {
        return 'Wrong';
      }
    }
    else {
      if(checkifUnattemted()) {
        return 'Unattemted'; 
      }
      else if(listEquals(isCorrect, userAns)) {
        return 'Correct';
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
            return 'Wrong';
          }
          else if(isCorrect[i] == true && userAns[i] == true) {
            tot_marks = tot_marks + atomMarks;
          }
        }
        return 'Partial Correct';
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

  int calcUnattemted() {
    int cnt = 0;
    for(int i=0 ; i<que.length ; i++) {
      if (que[i].checkifUnattemted()) {
        cnt = cnt  + 1;
      }
    }
    return cnt;
  }

  int calcAttemted() {
    int cnt = 0;
    for(int i=0 ; i<que.length ; i++) {
      if (!que[i].checkifUnattemted()) {
        cnt = cnt  + 1;
      }
    }
    return cnt;
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

  double evaluteAccuracy() {
    int len = que.length;
    double marks = 0.0;

    for(int i=0 ; i<len ; i++) {
      marks = marks + que[i].evalQuestion();
      print(' ${i+1}  ${marks}  ${que[i].evalQuestion()}');
    }

    return marks;
  }

  List<int> evalStats() {
    List<int> ret = [0, 0, 0, 0];

    for(int i=0 ; i<que.length ; i++) {
      String status = que[i].returnStatus();
      if(status == 'Correct') {
        ret[0] = ret[0] + 1;
      }
      else if(status == 'Partial Correct') {
        ret[1] = ret[1] + 1;
      }
      else if(status == 'Unattemted') {
        ret[2] = ret[2] + 1;
      }
      else {
        ret[3] = ret[3] + 1;
      }
    }

    return ret;
  }

}


class Result {
  String id;
  double marks;
  dynamic ans = [];

  Result({required this.id, required this.marks, required this.ans});


  factory Result.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Result(
      id: doc.id,
      marks: data['marks'],
      ans: data['ans']
    );
  }
}

Future<void> updateHomeInfo() async{
  createdTests = [];
  answeredTests = [];

  final prefs = await SharedPreferences.getInstance();
  var tmpUsername = prefs.getString('username');
  var tmpEmail = prefs.getString('email');
  if(tmpUsername != null && tmpEmail != null) {
    username = tmpUsername;
    email = tmpEmail;

    final db = FirebaseFirestore.instance;
    final doc = await db.collection('users').doc(username).get();
    createdTests = doc['createdTests'];
    answeredTests = doc['answeredTests'];
    print(answeredTests);
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


Future<int> getNumberOfResults(String quizId) async {
  try {
    
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tests')
        .doc(quizId)
        .collection('results')
        .get();

    print(querySnapshot);
    return querySnapshot.docs.length;
  } catch (error) {
    print('Error getting number of results: $error');
    return 0; // Return 0 in case of an error
  }
}


Future<Map?> getDocField(DocumentReference docRef) async {
  try {
    
    DocumentSnapshot docSnapshot = await docRef.get();

  
    if (docSnapshot.exists && docSnapshot.data() != null) {
      
      return {
        'name': docSnapshot.get('name'),
        'isActive': docSnapshot.get('isActive'),
        'isComplete': docSnapshot.get('isComplete'),
      };

    } else {
      print('Document does not exist or does not contain the name field');
      return null; 
    }
  } catch (error) {
    print('Error retrieving name field: $error');
    return null;  
  }
}


Future<void> getResultsInDescendingOrder(String quizId) async {

  try {
  
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('tests')
        .doc(quizId)
        .collection('results')
        .orderBy('marks', descending: true)  
        .get();

    resultList = [];
    for (var doc in querySnapshot.docs) {
      resultList.add(Result.fromFirestore(doc));
    }

  
  } catch (e) {
    print('Error retrieving results: $e');
  }
}


// Future<void> fetchUserAnswers() async{

//   try {
    
//     final db = FirebaseFirestore.instance;
//     DocumentReference docRef = db.collection('tests').doc(curr_quiz.id).collection('results').doc(username);
//     DocumentSnapshot docSnapshot = await docRef.get();
//     List<dynamic> tmpUserAns = docSnapshot.get('ans');

//     for(int i=0 ; i<curr_quiz.que.length ; i++) {
//       if(tmpUserAns[i]['userAns'] != null) {
//         curr_quiz.que[i].userAns = tmpUserAns[i]['userAns'] as List<bool>;
//       }
//     }    

//   }
//   catch(e) {
//     print('Error in results : $e');
//   }
// }

Future<void> fetchUserAnswers(String Username) async {
  try {
    final db = FirebaseFirestore.instance;
    DocumentReference docRef =
        db.collection('tests').doc(curr_quiz.id).collection('results').doc(Username);
    DocumentSnapshot docSnapshot = await docRef.get();

    List<dynamic> tmpUserAns = docSnapshot.get('ans');

    for (int i = 0; i < curr_quiz.que.length; i++) {
      if (tmpUserAns[i]['userAns'] != null) {
        // Ensure that each dynamic value is explicitly cast to bool
        curr_quiz.que[i].userAns = (tmpUserAns[i]['userAns'] as List<dynamic>)
            .map((e) => e as bool)
            .toList();
      }
    }
  } catch (e) {
    print('Error in results : $e');
  }
}


Future<bool> isUsernameAvailable(String username) async {
  try {
    // Get the Firestore instance
    final db = FirebaseFirestore.instance;

    // Reference to the document in 'users' collection with the given username
    DocumentReference docRef = db.collection('users').doc(username);

    // Fetch the document snapshot
    DocumentSnapshot docSnapshot = await docRef.get();

    // Check if the document exists
    if (docSnapshot.exists) {
      return false; // Username already exists
    } else {
      return true; // Username does not exist, user can create an account
    }
  } catch (e) {
    print('Error checking username: $e');
    return false; // In case of error, return false to be safe
  }
}

Future<bool> addUserToFirestore() async{

  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  Map<String, dynamic> userMap = {
    'username': username,
    'password': password,
    'email': email,
    'name': name,
    'phno': phno,
    'institute': institute,
    'createdTests': [],
    'answeredTests': [],
  };

  try {
    await usersCollection.doc(username).set(userMap);
    print('User saved successfully!');
    return true;
  } catch (e) {
    print('Failed to save user: $e');
    return false;
  }
}

