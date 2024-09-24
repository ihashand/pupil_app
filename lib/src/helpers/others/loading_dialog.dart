import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(30),
        width: 150,
        height: 200,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please wait...',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            SpinKitThreeBounce(
              color: Colors.blue,
              size: 35.0,
            ),
          ],
        ),
      ),
    );
  }
}
