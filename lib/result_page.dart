import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Container(
        child: Text('marks = ${curr_quiz.evaluateTest()}'),
      ),
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
      return Color.fromARGB(108, 76, 175, 79);
    }
    else if(curr_quiz.que[curr-1].userAns[index] == true) {
      return const Color.fromARGB(113, 244, 67, 54);
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
                height: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    _newQuestion.isMultipleCorrect 
                    ? const Text('\n   Choose one or more options')
                    : const Text('\n   Choose any one option'),

                    // Options Area
                    ListView.builder(
                      itemCount: _newQuestion.opt.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
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



              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromRGBO(255, 255, 255, 0.6),
                ),
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Status: '),
                        Text(_newQuestion.returnStatus()),
                      ],
                    ),

                    Row(
                      children: [
                        const Text('Marks Awarded: '),
                        Text(_newQuestion.evalQuestion().toString()),
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