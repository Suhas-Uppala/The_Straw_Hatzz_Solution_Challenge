import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class RiskPredictionScreen extends StatefulWidget {
  const RiskPredictionScreen({Key? key}) : super(key: key);

  @override
  _RiskPredictionScreenState createState() => _RiskPredictionScreenState();
}

Widget _buildTextField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
    ),
  );
}

class _RiskPredictionScreenState extends State<RiskPredictionScreen> {
  final TextEditingController trainingLoadController = TextEditingController();
  final TextEditingController hrvController = TextEditingController();
  final TextEditingController accelerationController = TextEditingController();
  final TextEditingController previousInjuryController =
      TextEditingController();
  final TextEditingController sleepHoursController = TextEditingController();
  final TextEditingController hydrationLevelController =
      TextEditingController();
  final TextEditingController fatigueScoreController = TextEditingController();

  String predictionResult = "";
  int riskScore = 0;
  bool showCharts = false;
  String selectedTimeRange = "Last 10 days";
  final List<String> timeRanges = [
    "Last 10 days",
    "1 month",
    "3 months",
    "6 months"
  ];
  final Map<String, List<int>> pastData = {};

  @override
  void initState() {
    super.initState();
    _initializePastData();
  }

  void _initializePastData() {
    final random = Random();
    for (var feature in [
      "Training Load",
      "HRV (ms)",
      "Acceleration (m/s²)",
      "Sleep Hours",
      "Hydration Level",
      "Fatigue Score"
    ]) {
      pastData[feature] = List.generate(180, (_) => random.nextInt(100));
    }
  }

  void predictRisk() {
    int trainingLoad = int.tryParse(trainingLoadController.text) ?? 0;
    int hrv = int.tryParse(hrvController.text) ?? 0;
    double acceleration = double.tryParse(accelerationController.text) ?? 0.0;
    int previousInjury = int.tryParse(previousInjuryController.text) ?? 0;
    double sleepHours = double.tryParse(sleepHoursController.text) ?? 0.0;
    int hydrationLevel = int.tryParse(hydrationLevelController.text) ?? 0;
    int fatigueScore = int.tryParse(fatigueScoreController.text) ?? 0;

    riskScore =
        trainingLoad + fatigueScore + (previousInjury * 20) - hydrationLevel;

    String riskMessage;
    if (riskScore < 50) {
      riskMessage = "🟢 Low Risk\n✅ Keep up the good work!";
    } else if (riskScore < 100) {
      riskMessage = "🟠 Medium Risk\n⚠ Reduce training and improve recovery.";
    } else {
      riskMessage = "🔴 High Risk\n❗ Take rest, hydrate, and consult a doctor.";
    }

    setState(() {
      predictionResult = riskMessage;
      showCharts = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Risk Prediction"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(trainingLoadController, "Training Load"),
              _buildTextField(hrvController, "HRV (ms)"),
              _buildTextField(accelerationController, "Acceleration (m/s²)"),
              _buildTextField(previousInjuryController,
                  "Previous Injury (1 for Yes, 0 for No)"),
              _buildTextField(sleepHoursController, "Sleep Hours"),
              _buildTextField(hydrationLevelController, "Hydration Level (%)"),
              _buildTextField(fatigueScoreController, "Fatigue Score (1-10)"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: predictRisk,
                child: const Text("Predict Risk"),
              ),
              const SizedBox(height: 20),
              if (predictionResult.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    predictionResult,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              if (showCharts)
                Column(
                  children: [
                    DropdownButton<String>(
                      value: selectedTimeRange,
                      items: timeRanges.map((String range) {
                        return DropdownMenuItem<String>(
                          value: range,
                          child: Text(range),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTimeRange = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureChart("Training Load"),
                    _buildFeatureChart("HRV (ms)"),
                    _buildFeatureChart("Acceleration (m/s²)"),
                    _buildFeatureChart("Sleep Hours"),
                    _buildFeatureChart("Hydration Level"),
                    _buildFeatureChart("Fatigue Score"),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChart(String label) {
    int days = _getDaysFromRange(selectedTimeRange);
    List<int> rawData = pastData[label]!.take(days).toList();

    List<FlSpot> graphData =
        (selectedTimeRange == "3 months" || selectedTimeRange == "6 months")
            ? _groupDataWeekly(rawData)
            : List.generate(rawData.length,
                (index) => FlSpot(index.toDouble(), rawData[index].toDouble()));

    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return _getXLabel(value, selectedTimeRange);
                    },
                    interval: 1,
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: graphData,
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _getXLabel(double value, String range) {
    int index = value.toInt();

    if (range == "Last 10 days") {
      return index % 2 == 0 ? Text("${index + 1}") : const Text("");
    } else if (range == "1 month") {
      return index % 7 == 0 ? Text("Week ${(index ~/ 7) + 1}") : const Text("");
    } else if (range == "3 months" || range == "6 months") {
      int monthIndex = (index ~/ 30) + 1;
      return index % 30 == 0 ? Text("Month $monthIndex") : const Text("");
    } else {
      return Text("${index + 1}");
    }
  }

  List<FlSpot> _groupDataWeekly(List<int> rawData) {
    List<FlSpot> weeklyData = [];
    for (int i = 0; i < rawData.length ~/ 7; i++) {
      double avg = rawData.skip(i * 7).take(7).reduce((a, b) => a + b) / 7;
      weeklyData.add(FlSpot(i.toDouble(), avg));
    }
    return weeklyData;
  }

  int _getDaysFromRange(String range) {
    return {
      "Last 10 days": 10,
      "1 month": 30,
      "3 months": 90,
      "6 months": 180
    }[range]!;
  }
}