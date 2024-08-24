import 'package:flutter/material.dart';

class ErrorHandlerWidget extends StatelessWidget {
  final Widget child;

  ErrorHandlerWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return ErrorHandler(
      child: child,
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;

  ErrorHandler({required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ErrorWidgetWrapper(child: child),
    );
  }
}

class ErrorWidgetWrapper extends StatefulWidget {
  final Widget child;

  ErrorWidgetWrapper({required this.child});

  @override
  _ErrorWidgetWrapperState createState() => _ErrorWidgetWrapperState();
}

class _ErrorWidgetWrapperState extends State<ErrorWidgetWrapper> {
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      _showErrorDialog(details.exception.toString(), details.stack.toString());
    };
  }

  void _showErrorDialog(String errorMessage, String stackTrace) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('An Error Occurred'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Error: $errorMessage'),
              SizedBox(height: 10),
              Text('Stack Trace: $stackTrace'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                // Optionally, you can add logic to retry the failed operation
              },
            ),
            TextButton(
              child: Text('Log Out'),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
