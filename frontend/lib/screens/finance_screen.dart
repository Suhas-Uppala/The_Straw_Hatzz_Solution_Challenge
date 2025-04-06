import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinanceScreen extends StatefulWidget {
  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  double balance = 125000; // Example balance (Can be fetched from backend)
  List<Map<String, dynamic>> sponsorships = [
    {
      "title": "Nike Athlete Sponsorship",
      "amount": "₹50,000",
      "status": "Apply Now"
    },
    {"title": "Adidas Rising Star", "amount": "₹75,000", "status": "Applied"},
    {
      "title": "Puma Training Grant",
      "amount": "₹30,000",
      "status": "Apply Now"
    },
  ];

  void applyForSponsorship(int index) {
    setState(() {
      sponsorships[index]['status'] = "Applied";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark theme for premium feel
      appBar: AppBar(
        title: Text("Athlete Finance Hub",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple[800],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceOverview(),
            SizedBox(height: 20),
            _buildFinanceChart(),
            SizedBox(height: 20),
            _buildAIInsights(),
            SizedBox(height: 20),
            _buildSponsorshipSection(),
            SizedBox(height: 20),
            _buildUpcomingPayments(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceOverview() {
    return Card(
      color: Colors.deepPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Balance Overview",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 10),
            Text("₹$balance",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.greenAccent),
                SizedBox(width: 5),
                Text("+12% from last month",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black87,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Financial Growth",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 7),
                        FlSpot(3, 10),
                        FlSpot(4, 12)
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                          colors: [Colors.greenAccent, Colors.lightGreen]),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepOrangeAccent,
      child: ListTile(
        leading: Icon(Icons.lightbulb, color: Colors.white),
        title: Text("AI Financial Insights",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
            "Reduce training costs by 15% with these 3 sponsorships!",
            style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildSponsorshipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Available Sponsorships",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 10),
        Column(
          children: sponsorships.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> sponsor = entry.value;
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.blueGrey[800],
              child: ListTile(
                leading: Icon(Icons.sports, color: Colors.yellowAccent),
                title: Text(sponsor["title"],
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text("Amount: ${sponsor["amount"]}",
                    style: TextStyle(color: Colors.white70)),
                trailing: ElevatedButton(
                  onPressed: sponsor["status"] == "Applied"
                      ? null
                      : () => applyForSponsorship(index),
                  child: Text(sponsor["status"]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sponsor["status"] == "Applied"
                        ? Colors.grey
                        : Colors.green,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUpcomingPayments() {
    return Column(
      children: [
        Text("Upcoming Payments",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 10),
        _buildFinanceItem(
            "Training Equipment", "-₹15,000", Colors.red, Icons.fitness_center),
        _buildFinanceItem(
            "Nutrition Plan", "-₹8,000", Colors.red, Icons.restaurant),
      ],
    );
  }

  Widget _buildFinanceItem(
      String title, String amount, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black87,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: Text(amount,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
