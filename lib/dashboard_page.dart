import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quiz_app/func_utils.dart';
import 'package:quiz_app/home_page.dart';
import 'package:quiz_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('U',
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: const BoxDecoration(color: Color(0xFF0094FF)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
              autofocus: true,
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async{
                Navigator.pop(context);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                await prefs.remove('email');
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Answered Tests",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "No. of Tests Answered : ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        user_dash.noAnsweredtests.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // pie chrt
                  SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: user_dash.stats[0].toDouble(),
                            title: '',
                            radius: 20,
                          ),
                          PieChartSectionData(
                            color: Colors.amber[200],
                            value: user_dash.stats[1].toDouble(),
                            radius: 20,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: Colors.red,
                            value: user_dash.stats[3].toDouble(),
                            radius: 20,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            color: Colors.grey,
                            value: user_dash.stats[2].toDouble(),
                            radius: 20,
                            showTitle: false,
                          ),
                        ],
                        centerSpaceRadius: 60,
                        startDegreeOffset: 270,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correct           : ${user_dash.stats[0].toString()}', style: const TextStyle(fontWeight: FontWeight.w600),),
                      Text('Partially Correct : ${user_dash.stats[1].toString()}', style: const TextStyle(fontWeight: FontWeight.w600),),
                      Text('Incorrct          : ${user_dash.stats[3].toString()}', style: const TextStyle(fontWeight: FontWeight.w600),),
                      Text('Unattemted        : ${user_dash.stats[2].toString()}', style: const TextStyle(fontWeight: FontWeight.w600),),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Created Tests",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text(
                    "No. of Tests Created : ",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    user_dash.noCreatedtests.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}