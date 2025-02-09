import 'package:flutter/material.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({Key? key}) : super(key: key);

  @override
  _CareerScreenState createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  int selectedTab = 0;
  final List<String> tabs = ["Overview", "Skills", "Opportunities", "Network"];

  void _onTabChanged(int index) {
    setState(() {
      selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: _buildTabs(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.work, color: Colors.white, size: 28),
          SizedBox(width: 8.0),
          Text(
            "Career Growth",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tabs.asMap().entries.map((entry) {
        int idx = entry.key;
        String tabName = entry.value;
        return GestureDetector(
          onTap: () => _onTabChanged(idx),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: selectedTab == idx ? Colors.blueGrey[700] : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              tabName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case 0:
        return _buildOverviewContent();
      case 1:
        return _buildSkillsContent();
      case 2:
        return _buildOpportunitiesContent();
      case 3:
        return _buildNetworkContent();
      default:
        return Container();
    }
  }

  Widget _buildOverviewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: 'AI Career Analysis',
          subtitle: 'Your performance metrics indicate strong growth potential.',
          footer: 'Updated Today',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoTile('Growth Score', '92/100'),
            const SizedBox(width: 16),
            _buildInfoTile('New Opportunities', '5'),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Core Competencies',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        const SizedBox(height: 12),
        _buildProgressBar('Sprint Speed', 0.95),
        _buildProgressBar('Endurance', 0.88),
        _buildProgressBar('Technique', 0.82),
      ],
    );
  }

  Widget _buildOpportunitiesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opportunities',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        const SizedBox(height: 12),
        _buildOpportunityCard(
          'National Athletics Championship',
          'Delhi • Aug 15-20',
          'High Match',
          'Apply',
        ),
        _buildOpportunityCard(
          'Sports Brand Partnership',
          'Sponsorship • Remote',
          'Medium Match',
          'View',
        ),
      ],
    );
  }

  Widget _buildNetworkContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Network',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent),
        ),
        const SizedBox(height: 12),
        _buildNetworkCard('John Doe', 'Coach & Mentor'),
        _buildNetworkCard('Jane Smith', 'Industry Expert'),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String footer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850], // Dark card background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(fontSize: 16, color: Colors.grey[300])),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(footer,
                style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 16, color: Colors.grey[300])),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, color: Colors.grey[300])),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Colors.grey[700],
              color: Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(
      String title, String subtitle, String match, String action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                const SizedBox(height: 4),
                Text(match,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Define action here.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkCard(String name, String role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.lightBlueAccent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(role,
                  style: TextStyle(fontSize: 14, color: Colors.grey[300])),
            ],
          )
        ],
      ),
    );
  }
}
