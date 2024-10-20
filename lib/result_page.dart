import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quiz_app/createtest_page.dart';
import 'package:quiz_app/func_utils.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    double score = curr_quiz.evaluateTest();
    double accur = curr_quiz.evaluteAccuracy();
    List<int> stats = curr_quiz.evalStats();
    

    return Scaffold(

      backgroundColor: const Color(0xFF0094FF),

      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back)),
        title: const Text('Result Page'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Your Score', style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E4E4E)
                    ),),

                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 15, 15, 0),
                          // color: Colors.amber,
                          width: 80,
                          height: 80,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: score.toDouble(),
                                  showTitle: false,
                                  radius: 8
                                ),
                                PieChartSectionData(
                                  color: Colors.grey,
                                  value: (curr_quiz.calcTotal().toDouble() - score.toDouble()).toDouble(),
                                  showTitle: false,
                                  radius: 8,
                                ),
                              ],
                              centerSpaceRadius: 24, // Space in the center
                              sectionsSpace: 2, 
                              startDegreeOffset: 270,
                            ),
                          ),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(' ${score.toStringAsFixed(2)}', style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4E4E4E)
                            ),),
                            Text('/${curr_quiz.calcTotal()}', style: const TextStyle(
                              color: Color(0xFF4E4E4E),
                              fontWeight: FontWeight.w500,
                            ),)
                          ],
                        )
                      ],

                      
                    ),
                  
                  
                ],
              ),
        
            ),




            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Details', style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E4E4E)
                    ),),

                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text('Total Questions      : ${curr_quiz.que.length}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Text('Attemted Questions   : ${curr_quiz.que.length - stats[2]}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Text('Unattemted Questions : ${stats[2]}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Text('Correct  Questions   : ${stats[0]}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Text('Partially Correct    : ${stats[1]}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Text('Incorrect Questions  : ${stats[3]}', style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),),

                          Center(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              // color: Colors.amber,
                              width: 300,
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: stats[0].toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.amber[200],
                                      value: stats[1].toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: stats[3].toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.grey,
                                      value: stats[2].toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                  ],
                                  centerSpaceRadius: 0, // Space in the center
                                sectionsSpace: 0, 
                                startDegreeOffset: 270,
                                )
                              ),
                            ),
                          )

                        ],
                      ),
                    )
                ],
              ),
        
            ),




            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              padding: const EdgeInsets.fromLTRB(20, 15, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.6),
              ),
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    const Text('Accuracy', style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E4E4E)
                    ),),

                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text('Your Accuracy is ${accur.toStringAsFixed(2)}%', style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),),

                          Center(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              // color: Colors.amber,
                              width: 300,
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: accur.toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      color: Colors.red,
                                      value: (100.toDouble() - accur.toDouble()).toDouble(),
                                      radius: 100,
                                      showTitle: false,
                                    ),
                                  ],
                                  centerSpaceRadius: 0, // Space in the center
                                sectionsSpace: 0, 
                                startDegreeOffset: 270,
                                )
                              ),
                            ),
                          )

                        ],
                      ),
                    ),


                ],
              ),
        
            ),


            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromRGBO(255, 255, 255, 0.6)
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                      MaterialPageRoute(
                        builder: (context) => const StatusPage(),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Check All Answers', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4E4E4E),
                    ),),
                    Icon(Icons.arrow_forward, color: Color(0xFF4E4E4E),)
                  ],
                  ),
              ),
            )
          ],
        ),
      )
    );
  }
}




































class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  int curr_q = 1; 
  Question _newQuestion = curr_quiz.at_loc(1);


  void _getQuestion(int index) {
    if (index > curr_quiz.que.length) {
      //do Nothing
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

  dynamic retBgCol(int curr, int index) {
    if (curr_quiz.que[curr-1].isCorrect[index] == true) {
      return const Color.fromARGB(108, 76, 175, 79);
    }
    else if(curr_quiz.que[curr-1].userAns[index] == true) {
      return const Color.fromARGB(113, 244, 67, 54);
    }
    else {
      return Colors.transparent;
    }
  }

  dynamic retCircleCol(int curr, int index) {
    if(curr_quiz.que[curr-1].userAns[index] == true) {
      return const Color.fromARGB(99, 47, 255, 64);
    }
    else {
      return Colors.white;
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
          title: const Text('Report'),
        ),
        
        
        bottomNavigationBar: BottomAppBar(
          color: const Color.fromRGBO(255, 255, 255, 0.75),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _getQuestion(curr_q - 1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(255, 145, 0, 1),
                    ),
                    child: const Text('Prev'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      
                      _getQuestion(curr_q + 1);

                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(6, 189, 0, 1),
                    ),
                    child: const Text('Next'),
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
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                          onTap: () {
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
                                    backgroundColor: retCircleCol(curr_q, index),
                                    radius: 10,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
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
                // height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Status: ', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E4E4E),
                        ),),
                        Text(_newQuestion.returnStatus(), style: TextStyle(
                          color: _newQuestion.returnStatus() == 'Correct' ? const Color(0xFF04CC00)
                          : _newQuestion.returnStatus() == 'Incorrect' ? Colors.red 
                          : _newQuestion.returnStatus() == 'Partial Correct' ? const Color(0xFFFFC700)
                          : const Color(0xFF4E4E4E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),),
                      ],
                    ),

                    Row(
                      children: [
                        const Text('Marks Awarded: ', style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E4E4E),
                        ),),
                        Text(_newQuestion.evalQuestion().toStringAsFixed(2), style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4E4E4E),
                        ),),
                      ],
                    )
                  ],
                )
                  
                
              ),



            ],
          ),
        ),
      ),
    );
  }

}