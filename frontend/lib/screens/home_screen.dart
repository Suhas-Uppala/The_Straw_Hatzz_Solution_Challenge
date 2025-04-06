import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'player_analytics.dart';
import '../main.dart'; // For AuthScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/SportAIfavicon.svg',
              height: 45, // Changed from 24 to 32
              width: 36, // Changed from 24 to 32
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            SizedBox(width: 8),
            Text("SportAI"),
          ],
        ),
        automaticallyImplyLeading: false, // remove default back button
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.indigo,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text("Today's Training",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                subtitle: Text("Sprint Training",
                    style: TextStyle(color: Colors.white70)),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text("Start"),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: _buildStatCard("Performance", "92%", Colors.green)),
                SizedBox(width: 10),
                Expanded(
                    child: _buildStatCard("Health Score", "95%", Colors.blue)),
              ],
            ),
            SizedBox(height: 20),
            Text("AI Insights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.lightbulb, color: Colors.indigo),
                title: Text("Training Recommendation"),
                subtitle: Text(
                    "Focus on recovery today. Your last session was intense."),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.chat, color: Colors.purple),
                title: Text("Communicate with Others"),
                subtitle: Text("Chat, schedule, and get help instantly."),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  onPressed: () {
                    _showInstructorDetails(context);
                  },
                  child: Text("Open"),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: 0.85, // Random score (85%)
                          strokeWidth: 8,
                          color: Colors.blue,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      Text("85%",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayerAnalyticsScreen()),
                      );
                    },
                    child: Text(
                      "View Player Analytics >",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20), // Keep some bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1), // Using a light shade of the status color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 16)),
            SizedBox(height: 5),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showInstructorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Instructor Details",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Text("J", style: TextStyle(color: Colors.white)),
                    ),
                    title: Text("Coach John Smith"),
                    subtitle: Text("Track & Field Coach"),
                  ),
                ),
                SizedBox(height: 20),
                Text("Communication Options",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.video_call, color: Colors.blue),
                  title: Text("Video Call"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Video Call option selected.")),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.schedule, color: Colors.green),
                  title: Text("Schedule"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Schedule option selected.")),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help_outline, color: Colors.orange),
                  title: Text("Ask a Question"),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Ask a Question option selected.")),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
