import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ai_coach_chat_screen.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({Key? key}) : super(key: key);

  @override
  _TrainingScreenState createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["All Plans", "Running", "Strength", "Recovery"];
  bool _isCheckingPosture = false; // Add this line

  Future<void> _togglePostureCheck() async {
    if (_isCheckingPosture) {
      // Stop posture detection
      try {
        final response = await http.post(
          Uri.parse('http://localhost:9000/stop'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          setState(() {
            _isCheckingPosture = false;
          });
          _showDialog(
            "Posture Check",
            "Posture detection stopped successfully",
          );
        } else {
          throw Exception('Failed to stop posture detection');
        }
      } catch (e) {
        debugPrint('Error stopping posture detection: $e');
        _showDialog(
          "Error",
          "Failed to stop posture detection. Please try again.",
        );
      }
    } else {
      // Start posture detection
      try {
        final response = await http.post(
          Uri.parse('http://localhost:9000/start'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          setState(() {
            _isCheckingPosture = true;
          });
          _showDialog(
            "Posture Check",
            "Posture detection started successfully. Keep your camera clear.",
          );
        } else {
          throw Exception('Failed to start posture detection');
        }
      } catch (e) {
        debugPrint('Error starting posture detection: $e');
        _showDialog(
          "Error",
          "Failed to start posture detection. Please check your camera and try again.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.fitness_center, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      "Training Hub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _tabs.length,
                    (index) => _buildTab(_tabs[index], index),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _togglePostureCheck,
        backgroundColor: _isCheckingPosture ? Colors.red : Colors.blue,
        icon: Icon(
          _isCheckingPosture ? Icons.stop : Icons.accessibility_new,
          color: Colors.white,
        ),
        label: Text(
          _isCheckingPosture ? 'Stop Check' : 'Check Posture',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = index == _selectedTabIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.white : Colors.grey[800],
          foregroundColor: isSelected ? Colors.deepPurple : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        onPressed: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAllPlansContent();
      case 1:
        return _buildRunningContent();
      case 2:
        return _buildStrengthContent();
      case 3:
        return _buildRecoveryContent();
      default:
        return Container();
    }
  }

  Widget _buildAllPlansContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: "AI Coach",
          subtitle: "Personalized training recommendations based on your data.",
          buttonText: "Ask AI Coach",
          buttonAction: _askAICoach,
          cardColor: Colors.purple,
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          title: "Today's Workout: Sprint Training",
          description: "High Intensity - 45 mins",
          steps: const [
            "Warm-up (10 mins)",
            "Sprint Intervals (25 mins)",
            "Cool-down (10 mins)"
          ],
        ),
        const SizedBox(height: 16),
        _buildAnalyticsSection(),
        const SizedBox(height: 16),
        _buildUpcomingSessions(),
        const SizedBox(height: 16),
        _buildPerformanceAnalytics(),
        const SizedBox(height: 16),
        _buildRunningForm(),
        const SizedBox(height: 16),
        _buildRecentSessions(),
        const SizedBox(height: 16),
        _buildHealthMonitoring(),
      ],
    );
  }

  Widget _buildRunningContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: "Running Coach",
          subtitle: "Improve your form and speed with targeted running drills.",
          buttonText: "View Running Tips",
          buttonAction: _showRunningTips,
          cardColor: Colors.teal,
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          title: "Today's Running Workout",
          description: "Interval Training - 30 mins",
          steps: const [
            "Jog Warm-up (5 mins)",
            "Intervals (20 mins)",
            "Cool-down (5 mins)"
          ],
        ),
        const SizedBox(height: 16),
        _buildAnalyticsCard("Avg Pace", "5:00 min/km"),
        const SizedBox(height: 16),
        _buildSessionCard("Long Run", "Sat, 7:00 AM", "Scheduled"),
      ],
    );
  }

  Widget _buildStrengthContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: "Strength Coach",
          subtitle: "Boost your muscle power with strength-focused workouts.",
          buttonText: "Get Strength Tips",
          buttonAction: _showStrengthTips,
          cardColor: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          title: "Today's Strength Workout",
          description: "Weight Training - 60 mins",
          steps: const [
            "Warm-up (10 mins)",
            "Weight Circuits (40 mins)",
            "Cool-down (10 mins)"
          ],
        ),
        const SizedBox(height: 16),
        _buildAnalyticsCard("Max Lift", "200 lbs"),
        const SizedBox(height: 16),
        _buildSessionCard("Gym Session", "Mon, 6:00 PM", "Confirmed"),
      ],
    );
  }

  Widget _buildRecoveryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: "Recovery Coach",
          subtitle: "Optimize recovery with stretching, yoga, and mindfulness.",
          buttonText: "View Recovery Plan",
          buttonAction: _showRecoveryPlan,
          cardColor: Colors.red,
        ),
        const SizedBox(height: 16),
        _buildWorkoutCard(
          title: "Today's Recovery Session",
          description: "Yoga and Stretching - 40 mins",
          steps: const [
            "Light Stretch (10 mins)",
            "Yoga Flow (20 mins)",
            "Meditation (10 mins)"
          ],
        ),
        const SizedBox(height: 16),
        _buildAnalyticsCard("Recovery Score", "85%"),
        const SizedBox(height: 16),
        _buildSessionCard("Recovery Session", "Tue, 8:00 AM", "Scheduled"),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback buttonAction,
    required Color cardColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.8), cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: buttonAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard({
    required String title,
    required String description,
    required List<String> steps,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value) {
    return GestureDetector(
      onTap: () => _showDialog(title, "More details about $title."),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Upcoming Sessions",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSessionCard(
            "Strength Training", "Tomorrow, 8:00 AM", "Scheduled"),
        const SizedBox(height: 8),
        _buildSessionCard("Recovery Session", "Wed, 4:30 PM", "Confirmed"),
      ],
    );
  }

  Widget _buildSessionCard(String title, String time, String status) {
    return GestureDetector(
      onTap: () =>
          _showDialog(title, "$title scheduled at $time.\nStatus: $status"),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(time, style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Text(
              status,
              style: TextStyle(
                color: status == "Scheduled" ? Colors.yellow : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return Row(
      children: [
        Expanded(child: _buildAnalyticsCard("Intensity", "8.5/10")),
        const SizedBox(width: 16),
        Expanded(child: _buildAnalyticsCard("Progress", "92%")),
      ],
    );
  }

  Widget _buildPerformanceAnalytics() {
    return GestureDetector(
      onTap: _showPerformanceAnalytics,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blueGrey[800],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "Performance Analytics\n(Tap to view detailed report)",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildRunningForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.teal[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Running Form Improvement\nEnhance your stride and reduce injury risk.",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: _showRunningForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("View Details",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions() {
    final List<Map<String, String>> sessions = [
      {"title": "Yoga", "details": "Relax and stretch session."},
      {"title": "Cycling", "details": "Endurance ride - 60 mins."},
      {"title": "HIIT", "details": "High intensity interval training."},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Recent Sessions",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        ...sessions.map(
          (session) => GestureDetector(
            onTap: () => _showDialog(session["title"]!, session["details"]!),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(session["title"]!,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthMonitoring() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Health Monitoring\nTrack your heart rate, steps, and sleep quality.",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: _showHealthMonitoring,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("View Stats",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _askAICoach() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AICoachChatScreen()),
    );
  }

  void _showRunningTips() {
    _showDialog("Running Tips",
        "Maintain a steady pace and focus on your breathing. Don't forget a proper warm-up and cool-down!");
  }

  void _showStrengthTips() {
    _showDialog("Strength Tips",
        "Focus on proper form and progressively increase your weights. Always include a warm-up to prevent injury.");
  }

  void _showRecoveryPlan() {
    _showDialog("Recovery Plan",
        "Incorporate stretching, yoga, and adequate rest days into your routine. Listen to your body to avoid overtraining.");
  }

  void _showPerformanceAnalytics() {
    _showDialog("Performance Analytics",
        "Detailed performance analytics are coming soon. Stay tuned for updates!");
  }

  void _showRunningForm() {
    _showDialog("Running Form",
        "Improve your running form by focusing on your posture, cadence, and foot strike. Consider drills and video analysis.");
  }

  void _showHealthMonitoring() {
    _showDialog("Health Monitoring",
        "Your current stats:\n• Heart Rate: 76 BPM\n• Steps: 10,500\n• Sleep: 7 hrs\nKeep up the great work!");
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(content, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close",
                  style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}
