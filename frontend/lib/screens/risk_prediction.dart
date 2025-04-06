import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class RiskPredictionScreen extends StatefulWidget {
  const RiskPredictionScreen({Key? key}) : super(key: key);

  @override
  _RiskPredictionScreenState createState() => _RiskPredictionScreenState();
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

  Map<String, String?> fieldErrors = {};

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

  String? validateTrainingLoad(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    int? load = int.tryParse(value);
    if (load == null) return "Must be a number";
    if (load < 0 || load > 100) return "Must be between 0 and 100";
    return null;
  }

  String? validateHRV(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    int? hrv = int.tryParse(value);
    if (hrv == null) return "Must be a number";
    if (hrv < 20 || hrv > 200) return "Must be between 20 and 200 ms";
    return null;
  }

  String? validateAcceleration(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    double? acc = double.tryParse(value);
    if (acc == null) return "Must be a number";
    if (acc < 0 || acc > 15) return "Must be between 0 and 15 m/s²";
    return null;
  }

  String? validatePreviousInjury(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    int? injury = int.tryParse(value);
    if (injury == null) return "Must be 0 or 1";
    if (injury != 0 && injury != 1) return "Must be 0 or 1";
    return null;
  }

  String? validateSleepHours(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    double? sleep = double.tryParse(value);
    if (sleep == null) return "Must be a number";
    if (sleep < 0 || sleep > 24) return "Must be between 0 and 24";
    return null;
  }

  String? validateHydration(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    int? hydration = int.tryParse(value);
    if (hydration == null) return "Must be a number";
    if (hydration < 0 || hydration > 100) return "Must be between 0 and 100%";
    return null;
  }

  String? validateFatigue(String? value) {
    if (value == null || value.isEmpty) return "Required field";
    int? fatigue = int.tryParse(value);
    if (fatigue == null) return "Must be a number";
    if (fatigue < 1 || fatigue > 10) return "Must be between 1 and 10";
    return null;
  }

  void predictRisk() {
    Map<String, String?> errors = {
      'training': validateTrainingLoad(trainingLoadController.text),
      'hrv': validateHRV(hrvController.text),
      'acceleration': validateAcceleration(accelerationController.text),
      'injury': validatePreviousInjury(previousInjuryController.text),
      'sleep': validateSleepHours(sleepHoursController.text),
      'hydration': validateHydration(hydrationLevelController.text),
      'fatigue': validateFatigue(fatigueScoreController.text),
    };

    setState(() {
      fieldErrors = errors;
    });

    if (errors.values.any((error) => error != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please correct the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    IconData? icon,
    String? Function(String?)? validator,
    String? errorText,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.blueAccent) : null,
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
          errorText: errorText,
          helperText: helperText,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (validator != null) {
            setState(() {
              validator(value);
            });
          }
        },
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Metrics",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(
                trainingLoadController,
                "Training Load",
                icon: Icons.fitness_center,
                errorText: fieldErrors['training'],
                helperText: "Enter a value between 0 and 100",
              ),
              _buildTextField(
                hrvController,
                "HRV (ms)",
                icon: Icons.favorite,
                errorText: fieldErrors['hrv'],
                helperText: "Enter a value between 20 and 200 ms",
              ),
              _buildTextField(accelerationController, "Acceleration (m/s²)",
                  icon: Icons.speed),
              SizedBox(height: 20),
              Text(
                "Health Indicators",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 10),
              _buildTextField(previousInjuryController,
                  "Previous Injury (1 for Yes, 0 for No)",
                  icon: Icons.medical_services),
              _buildTextField(sleepHoursController, "Sleep Hours",
                  icon: Icons.nightlight_round),
              _buildTextField(hydrationLevelController, "Hydration Level (%)",
                  icon: Icons.water_drop),
              _buildTextField(fatigueScoreController, "Fatigue Score (1-10)",
                  icon: Icons.battery_alert),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: predictRisk,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Predict Risk",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
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
