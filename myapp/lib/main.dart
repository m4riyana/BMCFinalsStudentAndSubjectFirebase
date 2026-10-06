import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'form_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration',
      home: const StudentRegistrationScreen(),
    );
  }
}

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends State<StudentRegistrationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController yearLevelController = TextEditingController();

  final List<TextEditingController> subjectControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<TextEditingController> scheduleControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  bool showSubjectSchedule = false;
  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    yearLevelController.dispose();

    for (final controller in subjectControllers) {
      controller.dispose();
    }

    for (final controller in scheduleControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void goToSubjectSchedule() {
    if (nameController.text.trim().isEmpty ||
        sectionController.text.trim().isEmpty ||
        yearLevelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all registration fields.'),
        ),
      );
      return;
    }

    setState(() {
      showSubjectSchedule = true;
    });
  }

  Future<void> saveStudentData() async {
    if (isSaving) return;

    final List<Map<String, String>> subjects = [];

    for (int i = 0; i < subjectControllers.length; i++) {
      final subject = subjectControllers[i].text.trim();
      final schedule = scheduleControllers[i].text.trim();

      if (subject.isNotEmpty || schedule.isNotEmpty) {
        subjects.add({
          'subject': subject,
          'schedule': schedule,
        });
      }
    }

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one subject and schedule.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final bool success = await FormPage.saveStudentData(
      name: nameController.text.trim(),
      section: sectionController.text.trim(),
      yearLevel: yearLevelController.text.trim(),
      subjects: subjects,
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Data saved successfully!'
              : 'Failed to save data. Please try again.',
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget buildStudentRegistration() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Student Registration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          buildTextField(
            label: 'Name',
            controller: nameController,
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Section',
            controller: sectionController,
          ),
          const SizedBox(height: 15),
          buildTextField(
            label: 'Yr. Level',
            controller: yearLevelController,
          ),
          const SizedBox(height: 25),
          Center(
            child: ElevatedButton(
              onPressed: goToSubjectSchedule,
              child: const Text('NEXT'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSubjectSchedule() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Subject Schedule',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ...List.generate(
            subjectControllers.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField(
                    label: 'Subject',
                    controller: subjectControllers[index],
                  ),
                  const SizedBox(height: 10),
                  buildTextField(
                    label: 'Schedule',
                    controller: scheduleControllers[index],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: ElevatedButton(
              onPressed: isSaving ? null : saveStudentData,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('SAVE'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: showSubjectSchedule
                  ? buildSubjectSchedule()
                  : buildStudentRegistration(),
            ),
          ),
        ),
      ),
    );
  }
}
