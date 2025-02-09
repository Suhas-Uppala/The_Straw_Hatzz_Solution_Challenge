import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Finance Manager")),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Finance Manager", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              SizedBox(height: 20),

              _buildBalanceOverview(),

              SizedBox(height: 20),

              Text("AI Financial Insights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildAIInsights(),

              SizedBox(height: 20),

              Text("Income Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildIncomeBreakdown(),

              SizedBox(height: 20),

              Text("Upcoming Payments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildUpcomingPayments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceOverview() {
    return Card(
      color: Colors.purple[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Balance Overview", style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 10),
            Text("₹1,25,000", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.greenAccent),
                SizedBox(width: 5),
                Text("+12% from last month", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsights() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.lightbulb, color: Colors.orange),
        title: Text("Optimize training expenses by 15%"),
        subtitle: Text("3 new sponsorship opportunities available"),
      ),
    );
  }

  Widget _buildIncomeBreakdown() {
    return Column(
      children: [
        _buildFinanceItem("Sponsorships", "₹75,000", Colors.indigo, Icons.monetization_on),
        _buildFinanceItem("Prize Money", "₹50,000", Colors.green, Icons.emoji_events),
      ],
    );
  }

  Widget _buildUpcomingPayments() {
    return Column(
      children: [
        _buildFinanceItem("Training Equipment", "-₹15,000", Colors.red, Icons.fitness_center),
        _buildFinanceItem("Nutrition Plan", "-₹8,000", Colors.red, Icons.restaurant),
      ],
    );
  }

  Widget _buildFinanceItem(String title, String amount, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}