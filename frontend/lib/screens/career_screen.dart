import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerScreen extends StatefulWidget {
  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  bool showAnalytics = false;
  bool showAllOpportunities = false;

  final TextEditingController _goalController = TextEditingController();
  List<String> goals = [];

  List<Map<String, String>> coaches = [
    {
      "name": "Coach A. Sharma",
      "expertise": "Sprint Specialist",
      "email": "asharma@coaching.com"
    },
    {
      "name": "Coach R. Singh",
      "expertise": "Strength & Conditioning",
      "email": "rsingh@coaching.com"
    },
    {
      "name": "Coach M. Verma",
      "expertise": "Mental Conditioning",
      "email": "mverma@coaching.com"
    },
  ];

  List<Map<String, String>> trainingTips = [
    {"tip": "Hydrate before and after training."},
    {"tip": "Track your sleep and recovery."},
    {"tip": "Use dynamic warm-ups to avoid injuries."},
  ];

  List<Map<String, String>> initialOpportunities = [
    {
      "title": "National Athletics Championship",
      "location": "Delhi • Aug 15-20",
      "match": "High Match",
      "details":
          "Compete with top athletes. Includes 100m, 200m, and distance events.",
      "url": "https://www.sportsauthorityofindia.nic.in/"
    },
    {
      "title": "International Sports Expo",
      "location": "Bangalore • Sep 5-7",
      "match": "Medium Match",
      "details": "Network with brands. Workshops and exhibitions for athletes.",
      "url": "https://olympics.com/en/"
    },
    {
      "title": "University Talent Hunt",
      "location": "Mumbai • Oct 10",
      "match": "High Match",
      "details": "Scholarships via trials. Top 5 get training sponsorship.",
      "url": "https://www.aicte-india.org/"
    },
  ];

  List<Map<String, String>> moreOpportunities = [
    {
      "title": "State Sports Meet",
      "location": "Lucknow • Nov 3-5",
      "match": "Medium Match",
      "details":
          "Participate in a wide range of track and field events. Entry by trials.",
      "url": "https://yas.nic.in/"
    },
    {
      "title": "Winter Coaching Camp",
      "location": "Shimla • Dec 1-15",
      "match": "Low Match",
      "details": "Skill enhancement camp for sprinters, jumpers, and throwers.",
      "url": "https://sportscoachingfoundation.com/"
    },
    {
      "title": "Asian Games Trials",
      "location": "Chennai • Jan 10-12",
      "match": "High Match",
      "details":
          "Trials for athletes aspiring to participate in Asian Games. Intense competition.",
      "url": "https://indianathletics.in/"
    },
  ];

  List<bool> expandedList = List.filled(6, false);

  void _toggleExpansion(int index) {
    setState(() {
      expandedList[index] = !expandedList[index];
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Could not launch URL"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void _addGoal() {
    if (_goalController.text.trim().isNotEmpty) {
      setState(() {
        goals.add(_goalController.text.trim());
        _goalController.clear();
      });
    }
  }

  void _sendEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Coaching Inquiry&body=Hello Coach, I would like to discuss training opportunities.',
    );

    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Could not open email app"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedOpportunities = showAllOpportunities
        ? [...initialOpportunities, ...moreOpportunities]
        : initialOpportunities;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Career Growth for Athletes",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerMessage(),
          const SizedBox(height: 16),
          _infoCard(),
          const SizedBox(height: 16),
          _analyticsCard(),
          const SizedBox(height: 16),
          _goalTracker(),
          const SizedBox(height: 16),
          _coachSection(),
          const SizedBox(height: 16),
          _trainingTipsSection(),
          const SizedBox(height: 16),
          Text("Opportunities",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          ..._buildOpportunitiesList(displayedOpportunities),
          if (!showAllOpportunities)
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAllOpportunities = true;
                  });
                },
                child: const Text("View More",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerMessage() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          "🎯 Welcome, Champion!\nTrack progress, set goals, find coaches, and grow with tech.",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your Current Progress",
                style: TextStyle(color: Colors.black, fontSize: 18)),
            const SizedBox(height: 10),
            _buildInfoRow("Present Level", "State Level"),
            _buildInfoRow("Next Level", "National Level"),
            _buildInfoRow("Matches Played", "12"),
            _buildInfoRow("Victories", "9"),
            _buildInfoRow("Avg. Speed", "24.5 km/h"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(title, style: const TextStyle(color: Colors.black54))),
          Text(value,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _analyticsCard() {
    return Card(
      color: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Performance Analytics",
                style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showAnalytics = !showAnalytics;
                });
              },
              icon: const Icon(Icons.bar_chart),
              label: Text(showAnalytics ? "Hide Analytics" : "View Analytics"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
            ),
            if (showAnalytics) _buildLineChart(),
          ],
        ),
      ),
    );
  }

  Widget _goalTracker() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎯 Set Career Goals",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            TextField(
              controller: _goalController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter your next goal",
                hintStyle: const TextStyle(color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addGoal,
                ),
              ),
            ),
            ...goals.map((goal) => ListTile(
                  title:
                      Text(goal, style: const TextStyle(color: Colors.white)),
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                )),
          ],
        ),
      ),
    );
  }

  Widget _coachSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("👥 Coaches & Mentors",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 10),
            ...coaches.map((coach) => ListTile(
                  title: Text(coach['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  subtitle: Text(coach['expertise']!,
                      style: const TextStyle(color: Colors.black54)),
                  leading: const Icon(Icons.person, color: Colors.blue),
                  trailing: ElevatedButton.icon(
                    onPressed: () => _sendEmail(coach['email']!),
                    icon: const Icon(Icons.email),
                    label: const Text("Contact"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _trainingTipsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🏋 Training Tips",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            ...trainingTips.map((tip) => ListTile(
                  leading:
                      const Icon(Icons.fitness_center, color: Colors.white),
                  title: Text(tip['tip']!,
                      style: const TextStyle(color: Colors.white)),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: true),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    const days = [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    return Text(days[value.toInt()],
                        style: const TextStyle(color: Colors.white));
                  }),
            ),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(value.toString(),
                          style: const TextStyle(color: Colors.white));
                    })),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 5),
                FlSpot(1, 6),
                FlSpot(2, 6.5),
                FlSpot(3, 7),
                FlSpot(4, 6.8),
                FlSpot(5, 7.2),
                FlSpot(6, 7.5),
              ],
              isCurved: true,
              color: Colors.yellowAccent,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: Colors.yellow.withOpacity(0.3)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOpportunitiesList(
      List<Map<String, String>> opportunities) {
    return List.generate(opportunities.length, (index) {
      final opp = opportunities[index];
      final isExpanded = expandedList[index];
      final matchColor = opp['match'] == "High Match"
          ? Colors.green
          : opp['match'] == "Medium Match"
              ? Colors.orange
              : Colors.red;

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white12),
        ),
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              title: Text(opp["title"]!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              subtitle: Text(opp["location"]!,
                  style: const TextStyle(color: Colors.black54)),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: matchColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(opp["match"]!,
                    style: TextStyle(
                        color: matchColor, fontWeight: FontWeight.bold)),
              ),
            ),
            if (isExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(opp["details"]!,
                    style: const TextStyle(color: Colors.black)),
              ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _toggleExpansion(index),
                  child: Text(isExpanded ? "Hide Details" : "View Details",
                      style: const TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  onPressed: () => _launchURL(opp["url"]!),
                  child: const Text("Apply Now"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}