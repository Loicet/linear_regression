import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const kNavy = Color(0xFF0A2342);
const kTeal = Color(0xFF008080);
const kSkyBlue = Color(0xFF87CEEB);
const kWhite = Colors.white;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kTeal),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── HOME SCREEN ────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNavy,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kTeal.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: kTeal, width: 2),
                  ),
                  child: const Icon(Icons.monitor_heart, size: 72, color: kSkyBlue),
                ),
                const SizedBox(height: 32),
                const Text(
                  'WeCare',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: kWhite,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Predict fasting glucose levels using your health & lifestyle data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: kWhite.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PredictionScreen()),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Start Prediction', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kTeal,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── PREDICTION SCREEN ──────────────────────────────────────────────────────

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  double? _result;

  // Controllers for numeric fields
  final _age = TextEditingController();
  final _alcohol = TextEditingController();
  final _activity = TextEditingController();
  final _diet = TextEditingController();
  final _sleep = TextEditingController();
  final _screen = TextEditingController();
  final _bmi = TextEditingController();
  final _waist = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _heartRate = TextEditingController();
  final _cholTotal = TextEditingController();
  final _hdl = TextEditingController();
  final _ldl = TextEditingController();
  final _triglycerides = TextEditingController();
  final _glucosePost = TextEditingController();
  final _insulin = TextEditingController();
  final _hba1c = TextEditingController();

  // Categorical
  String? _gender;
  String? _ethnicity;
  String? _education;
  String? _income;
  String? _employment;
  String? _smoking;

  // Binary
  int _familyHistory = 0;
  int _hypertension = 0;
  int _cardiovascular = 0;

  @override
  void dispose() {
    for (final c in [_age, _alcohol, _activity, _diet, _sleep, _screen, _bmi, _waist, _systolic, _diastolic, _heartRate, _cholTotal, _hdl, _ldl, _triglycerides, _glucosePost, _insulin, _hba1c]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _result = null; });

    final body = {
      "Age": double.parse(_age.text),
      "alcohol_consumption_per_week": double.parse(_alcohol.text),
      "physical_activity_minutes_per_week": double.parse(_activity.text),
      "diet_score": double.parse(_diet.text),
      "sleep_hours_per_day": double.parse(_sleep.text),
      "screen_time_hours_per_day": double.parse(_screen.text),
      "family_history_diabetes": _familyHistory,
      "hypertension_history": _hypertension,
      "cardiovascular_history": _cardiovascular,
      "bmi": double.parse(_bmi.text),
      "waist_to_hip_ratio": double.parse(_waist.text),
      "systolic_bp": double.parse(_systolic.text),
      "diastolic_bp": double.parse(_diastolic.text),
      "heart_rate": double.parse(_heartRate.text),
      "cholesterol_total": double.parse(_cholTotal.text),
      "hdl_cholesterol": double.parse(_hdl.text),
      "ldl_cholesterol": double.parse(_ldl.text),
      "triglycerides": double.parse(_triglycerides.text),
      "glucose_postprandial": double.parse(_glucosePost.text),
      "insulin_level": double.parse(_insulin.text),
      "hba1c": double.parse(_hba1c.text),
      "gender_Male": _gender == 'Male' ? 1 : 0,
      "gender_Other": _gender == 'Other' ? 1 : 0,
      "ethnicity_Black": _ethnicity == 'Black' ? 1 : 0,
      "ethnicity_Hispanic": _ethnicity == 'Hispanic' ? 1 : 0,
      "ethnicity_Other": _ethnicity == 'Other' ? 1 : 0,
      "ethnicity_White": _ethnicity == 'White' ? 1 : 0,
      "education_level_Highschool": _education == 'Highschool' ? 1 : 0,
      "education_level_No_formal": _education == 'No formal' ? 1 : 0,
      "education_level_Postgraduate": _education == 'Postgraduate' ? 1 : 0,
      "income_level_Low": _income == 'Low' ? 1 : 0,
      "income_level_Lower_Middle": _income == 'Lower-Middle' ? 1 : 0,
      "income_level_Middle": _income == 'Middle' ? 1 : 0,
      "income_level_Upper_Middle": _income == 'Upper-Middle' ? 1 : 0,
      "employment_status_Retired": _employment == 'Retired' ? 1 : 0,
      "employment_status_Student": _employment == 'Student' ? 1 : 0,
      "employment_status_Unemployed": _employment == 'Unemployed' ? 1 : 0,
      "smoking_status_Former": _smoking == 'Former' ? 1 : 0,
      "smoking_status_Never": _smoking == 'Never' ? 1 : 0,
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _result = data['predicted_glucose_fasting'].toDouble());
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Could not connect to server.');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FB),
      appBar: AppBar(
        backgroundColor: kNavy,
        foregroundColor: kWhite,
        title: const Text('Glucose Prediction', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              icon: Icons.person,
              title: 'Personal Info',
              children: [
                _numField(_age, 'Age', Icons.cake),
                _dropdown('Gender', ['Male', 'Female', 'Other'], _gender, (v) => setState(() => _gender = v), Icons.wc),
                _dropdown('Ethnicity', ['Asian', 'Black', 'Hispanic', 'Other', 'White'], _ethnicity, (v) => setState(() => _ethnicity = v), Icons.people),
                _dropdown('Education Level', ['College', 'Highschool', 'No formal', 'Postgraduate'], _education, (v) => setState(() => _education = v), Icons.school),
                _dropdown('Income Level', ['High', 'Low', 'Lower-Middle', 'Middle', 'Upper-Middle'], _income, (v) => setState(() => _income = v), Icons.attach_money),
                _dropdown('Employment Status', ['Employed', 'Retired', 'Student', 'Unemployed'], _employment, (v) => setState(() => _employment = v), Icons.work),
              ],
            ),
            _section(
              icon: Icons.self_improvement,
              title: 'Lifestyle',
              children: [
                _numField(_alcohol, 'Alcohol Consumption (per week)', Icons.local_bar),
                _numField(_activity, 'Physical Activity (min/week)', Icons.directions_run),
                _numField(_diet, 'Diet Score (0–10)', Icons.restaurant),
                _numField(_sleep, 'Sleep Hours per Day', Icons.bedtime),
                _numField(_screen, 'Screen Time Hours per Day', Icons.phone_android),
                _dropdown('Smoking Status', ['Current', 'Former', 'Never'], _smoking, (v) => setState(() => _smoking = v), Icons.smoking_rooms),
              ],
            ),
            _section(
              icon: Icons.medical_information,
              title: 'Health History',
              children: [
                _toggle('Family History of Diabetes', _familyHistory, (v) => setState(() => _familyHistory = v)),
                _toggle('Hypertension History', _hypertension, (v) => setState(() => _hypertension = v)),
                _toggle('Cardiovascular History', _cardiovascular, (v) => setState(() => _cardiovascular = v)),
              ],
            ),
            _section(
              icon: Icons.monitor_weight,
              title: 'Body Metrics',
              children: [
                _numField(_bmi, 'BMI', Icons.accessibility_new),
                _numField(_waist, 'Waist-to-Hip Ratio', Icons.straighten),
                _numField(_systolic, 'Systolic BP (mmHg)', Icons.favorite),
                _numField(_diastolic, 'Diastolic BP (mmHg)', Icons.favorite_border),
                _numField(_heartRate, 'Heart Rate (bpm)', Icons.monitor_heart),
              ],
            ),
            _section(
              icon: Icons.science,
              title: 'Lab Results',
              children: [
                _numField(_cholTotal, 'Total Cholesterol (mg/dL)', Icons.biotech),
                _numField(_hdl, 'HDL Cholesterol (mg/dL)', Icons.biotech),
                _numField(_ldl, 'LDL Cholesterol (mg/dL)', Icons.biotech),
                _numField(_triglycerides, 'Triglycerides (mg/dL)', Icons.water_drop),
                _numField(_glucosePost, 'Postprandial Glucose (mg/dL)', Icons.bloodtype),
                _numField(_insulin, 'Insulin Level (µU/mL)', Icons.vaccines),
                _numField(_hba1c, 'HbA1c (%)', Icons.percent),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _predict,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: kWhite, strokeWidth: 2))
                    : const Icon(Icons.analytics),
                label: Text(_loading ? 'Predicting...' : 'Predict Glucose'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _resultCard(_result!),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section({required IconData icon, required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: kTeal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy, fontSize: 15)),
        initiallyExpanded: true,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: _inputDecoration(label, icon),
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      ),
    );
  }

  Widget _dropdown(String label, List<String> options, String? value, ValueChanged<String?> onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: _inputDecoration(label, icon),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _toggle(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: kNavy)),
          Switch(
            value: value == 1,
            onChanged: (v) => onChanged(v ? 1 : 0),
            activeColor: kTeal,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kTeal, size: 20),
      filled: true,
      fillColor: kSkyBlue.withOpacity(0.15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: kTeal, width: 1.5)),
      labelStyle: const TextStyle(fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );
  }

  Widget _resultCard(double glucose) {
    final isNormal = glucose < 100;
    final isPreDiabetic = glucose >= 100 && glucose < 126;
    final color = isNormal ? Colors.green : isPreDiabetic ? Colors.orange : Colors.red;
    final status = isNormal ? 'Normal' : isPreDiabetic ? 'Pre-Diabetic Range' : 'Diabetic Range';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: kNavy.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Text('Predicted Fasting Glucose', style: TextStyle(color: kSkyBlue, fontSize: 14)),
          const SizedBox(height: 8),
          Text('${glucose.toStringAsFixed(1)} mg/dL',
              style: const TextStyle(color: kWhite, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
