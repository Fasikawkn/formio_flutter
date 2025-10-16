import 'package:flutter/material.dart';
import 'package:formio/formio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormIO Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Modern FormIO Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FormModel form;
  int index = 0;

  @override
  void initState() {
    super.initState();
    form = FormModel.fromJson(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: FormRenderer(
          form: form,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Map<String, dynamic> jsonData = {
  '_id': '64a7b1f4e4b0c9001cfa5f3d',
  'path': 'registration',
  'title': 'Modern Registration Form',
  'name': 'registration',
  "components": [
    {
      "label": "Email",
      "placeholder": "work email",
      "applyMaskOn": "change",
      "tableView": true,
      "validate": {"required": true},
      "validateWhenHidden": false,
      "key": "email",
      "type": "email",
      "input": true,
    },
    {
      "label": "Task delivery",
      "placeholder": "2025-10-16 12:00 PM",
      "tableView": false,
      "datePicker": {"disableWeekends": false, "disableWeekdays": false},
      "enableMinDateInput": false,
      "enableMaxDateInput": false,
      "validateWhenHidden": false,
      "key": "taskDelivery",
      "type": "datetime",
      "input": true,
      "widget": {
        "type": "calendar",
        "displayInTimezone": "viewer",
        "locale": "en",
        "useLocaleSettings": false,
        "allowInput": true,
        "mode": "single",
        "enableTime": true,
        "noCalendar": false,
        "format": "yyyy-MM-dd hh:mm a",
        "hourIncrement": 1,
        "minuteIncrement": 1,
        "time_24hr": false,
        "minDate": null,
        "disableWeekends": false,
        "disableWeekdays": false,
        "maxDate": null,
      },
    },
    {
      "label": "Attachment",
      "description": "File Upload Description",
      "tooltip": "Tooltip message",
      "tableView": false,
      "webcam": false,
      "capture": false,
      "fileTypes": [
        {"label": "", "value": ""},
      ],
      "validate": {"required": true},
      "validateWhenHidden": false,
      "key": "attachment",
      "type": "file",
      "input": true,
    },
    {
      "label": "Signature",
      "tableView": false,
      "validate": {"required": true},
      "validateWhenHidden": false,
      "key": "signature",
      "type": "signature",
      "input": true,
    },
    {
      "type": "button",
      "label": "Submit",
      "key": "submit",
      "disableOnInvalid": true,
      "input": true,
      "tableView": false,
    },
  ],
};
