import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/result_page.dart';

bool isActive = false; 
int noofUsers = 0;


class TestadminPage extends StatefulWidget {
  const TestadminPage({super.key, required this.testId});

  final testId ;

  @override
  State<TestadminPage> createState() => _TestadminPageState(testId);
}

class _TestadminPageState extends State<TestadminPage> {
  _TestadminPageState(this.testId);
  String testId = '';
  bool st = false;

   Future<void> fetchIsActive() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('tests')
          .doc(curr_quiz.id)
          .get();

      if (doc.exists) {
        setState(() {
          isActive = doc['isActive']; // Fetch the 'isActive' value
        });
      } else {
        print('Test document does not exist.');
        setState(() {
        });
      }
    } catch (error) {
      print('Error fetching isActive: $error');
      setState(() {
      });
    }
  }

  Future<void> updateIsActive(bool newValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('tests')
          .doc(curr_quiz.id)
          .update({'isActive': newValue});
      print('isActive updated to $newValue');
    } catch (error) {
      print('Error updating isActive: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF0094FF),

      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back)),
        title: const Text('Test Admin'),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromRGBO(255, 255, 255, 0.6),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Test Code: $testId', style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16, 
                      color: Color(0xFF3F3F3F)),
                    ),

                    Material(
                      color: Colors.transparent,
                  
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () async{
                          await Clipboard.setData(ClipboardData(text: curr_quiz.id));
                        },
                        child: const SizedBox(
                            child: Icon(Icons.copy, size: 14,),    
                          
                        ),
                      ),
                    ),
                  ],
                ),
                Text('Test Name: ${curr_quiz.name}', style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF3F3F3F)),
                ),
                Text('Test Duration : ${curr_quiz.time}',style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF3F3F3F)), 
                
                ),
                
              ],
            ),
          ),

          Container(
            width: double.infinity,
            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromRGBO(255, 255, 255, 0.6),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(20, 10, 20,10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Activate Test: ',style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: Color(0xFF3F3F3F)), 
                
                ),

                
                Switch(
                    value: isActive,
                    onChanged: (bool newValue) {
                      setState(() {
                        isActive = newValue;
                      });
                      updateIsActive(newValue); // Update Firestore when the switch is toggled
                    },
                  ),




              ],
            ),
          ),

          Container(
            width: double.infinity,
            
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromRGBO(255, 255, 255, 0.6),
            ),
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Details ',style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 18, 
                  color: Color(0xFF3F3F3F)), 
                
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Row(
                    children: [
                      const Text('No. of Students Answered: ',style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: Color(0xFF3F3F3F)), 
                      
                      ),

                      Text(resultList.length.toString(), style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16, 
                        color: Color(0xFF3F3F3F)), ),
                    ],
                  ),
                ),


              ],
            ),
          ),

          GestureDetector(
            onTap: () async{
              // await getResultsInDescendingOrder(curr_quiz.id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => ResultListPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('List of users answered test',style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18, 
                      color: Color(0xFF3F3F3F)), 
                    
                  ),
            
                  Icon(Icons.arrow_forward, 
                    color: Color(0xFF3F3F3F),
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}






















































class ResultListPage extends StatefulWidget {
  @override
  _ResultListPageState createState() => _ResultListPageState();
}

class _ResultListPageState extends State<ResultListPage> {
  List<dynamic> filteredResults = resultList;
  TextEditingController searchController = TextEditingController();

  // Filter the result list based on search input
  void _filterResults(String query) {
    setState(() {
      filteredResults = resultList
          .where((result) => result.id.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(curr_quiz.id),
        backgroundColor: Colors.lightBlue[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous page
          },
        ),
      ),
      body: Container(
        color: Color(0xFF0094FF),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                onChanged: _filterResults,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredResults.length,
                itemBuilder: (context, index) {
                  Result result = filteredResults[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.0),
                    child: Card(
                      color: const Color(0xFF99D4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(result.id),
                        trailing: Text(result.marks.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            )),
                        onTap: () async{
                          // Placeholder for navigating to another page when clicked
                          await fetchUserAnswers(result.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatusPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder page for when a list tile is clicked
class PlaceholderPage extends StatelessWidget {
  final Result result;

  PlaceholderPage({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(result.id),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text('Details for ${result.id}, Marks: ${result.marks}'),
      ),
    );
  }
}
