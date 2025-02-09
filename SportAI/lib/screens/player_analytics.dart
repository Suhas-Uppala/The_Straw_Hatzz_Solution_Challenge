import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class PlayerAnalyticsScreen extends StatefulWidget {
  const PlayerAnalyticsScreen({super.key});

  @override
  _PlayerAnalyticsScreenState createState() => _PlayerAnalyticsScreenState();
}

class _PlayerAnalyticsScreenState extends State<PlayerAnalyticsScreen> {
  late Map<DateTime, List<String>> _events;
  late List<String> _selectedEvents;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = {};
    _selectedEvents = [];
    _selectedDay = DateTime.now();
  }

  void _addEvent(String event) {
    setState(() {
      if (_events[_selectedDay] != null) {
        _events[_selectedDay]!.add(event);
      } else {
        _events[_selectedDay] = [event];
      }
      _selectedEvents = _events[_selectedDay]!;
    });
  }

  void _deleteEvent(String event) {
    setState(() {
      _events[_selectedDay]!.remove(event);
      _selectedEvents = _events[_selectedDay]!;
    });
  }

  void _editEvent(String oldEvent, String newEvent) {
    setState(() {
      int index = _events[_selectedDay]!.indexOf(oldEvent);
      _events[_selectedDay]![index] = newEvent;
      _selectedEvents = _events[_selectedDay]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Player Analytics")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Training Summary & Trends"),
            _buildGradientLineChart("Weekly Training Hours", [4, 5, 6, 5, 7, 6, 8], "Days", "Hours"),
            _buildGradientLineChart("Intensity Breakdown", [50, 60, 75, 80, 90, 85, 95], "Days", "Intensity"),
            
            _buildSectionTitle("Performance Progress"),
            _buildAnimatedBarChart("Personal Best & Recent Improvements", [200, 210, 220, 230, 240], "Attempts", "Performance"),
            
            _buildSectionTitle("Goal Tracking Dashboard"),
            _buildGoalTrackingDashboard(),
            
            _buildSectionTitle("Injury Risk & Recovery"),
            _buildIndicator("Injury Risk", "Moderate", Colors.orange),
            _buildIndicator("Recovery Score", "Good", Colors.green),
            
            _buildSectionTitle("Biometric & Health Data"),
            _buildGradientLineChart("Average Heart Rate", [75, 78, 80, 76, 74, 72, 70], "Days", "BPM"),
            
            _buildSectionTitle("Nutrition & Caloric Balance"),
            _buildRealPieChart(),
            
            _buildSectionTitle("AI-Generated Insights & Recommendations"),
            _buildAIInsight("Consider adding 10 minutes of mobility work after sessions"),
            _buildAIInsight("Your recovery metrics suggest an extra rest day"),
            
            _buildSectionTitle("Activity Calendar & Session Highlights"),
            _buildCalendar(),
            ..._selectedEvents.map((event) => ListTile(
              title: Text(event),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteEvent(event),
              ),
              onTap: () => _editEvent(event, "Edited Event"),
            )),
            TextField(
              onSubmitted: (value) => _addEvent(value),
              decoration: InputDecoration(
                labelText: "Add Event",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
          child: Text(value, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildGradientLineChart(String title, List<double> dataPoints, String xAxisLabel, String yAxisLabel) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey, strokeWidth: 0.5);
                  }),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(dataPoints.length, (index) => FlSpot(index.toDouble(), dataPoints[index])),
                      isCurved: true,
                      gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.1)])),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(xAxisLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            Text(yAxisLabel, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBarChart(String title, List<double> values, String xAxisLabel, String yAxisLabel) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: values.reduce((a, b) => a > b ? a : b) + 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: values.asMap().entries.map((entry) {
                    int index = entry.key;
                    double value = entry.value;
                    return BarChartGroupData(x: index, barRods: [
                      BarChartRodData(toY: value, gradient: const LinearGradient(colors: [Colors.lightBlueAccent, Colors.blueAccent])) // Corrected parameter names
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(xAxisLabel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            Text(yAxisLabel, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        SizedBox(
          height: 80,
          width: 80,
          child: Stack(
            children: [
              CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: Colors.grey[300], color: Colors.blue),
              Center(child: Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRealPieChart() {
    return SizedBox(
      height: 150,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 40, color: Colors.blue, title: 'Protein'),
            PieChartSectionData(value: 30, color: Colors.red, title: 'Carbs'),
            PieChartSectionData(value: 30, color: Colors.green, title: 'Fats'),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _selectedDay,
          calendarFormat: CalendarFormat.month,
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          daysOfWeekStyle: const DaysOfWeekStyle(weekendStyle: TextStyle(color: Colors.red)),
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _selectedEvents = _events[selectedDay] ?? [];
            });
          },
          eventLoader: (day) {
            return _events[day] ?? [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: _buildEventMarker(events.length),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        ..._selectedEvents.map((event) => ListTile(
          title: Text(event),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _editEvent(event, "Edited Event"); // Example edit action
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteEvent(event),
              ),
            ],
          ),
        )),
        TextField(
          onSubmitted: (value) => _addEvent(value),
          decoration: InputDecoration(
            labelText: "Add Event",
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventMarker(int eventCount) {
    return Container(
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      width: 16,
      height: 16,
      child: Center(
        child: Text(
          '$eventCount',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAIInsight(String message) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.yellow),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildGoalTrackingDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCircularProgress("Increase Deadlift by 20kg", 0.7),
        _buildCircularProgress("Improve Sprint Time by 0.5s", 0.5),
      ],
    );
  }
}