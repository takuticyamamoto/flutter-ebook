import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PercentIndigator extends StatefulWidget {
  const PercentIndigator({super.key});

  @override
  State<PercentIndigator> createState() => _PercentIndigatorState();
}

class _PercentIndigatorState extends State<PercentIndigator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text("Circular Percent Indicators")),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15.0),
              child: new CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 5.0,
                percent: 1.0,
                center: new Text("100%"),
                progressColor: Colors.green,
              ),
            ),
            Container(
              padding: EdgeInsets.all(15.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 4.0,
                    percent: 0.10,
                    center: new Text("10%"),
                    progressColor: Colors.red,
                  ),
                  new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                  new CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 4.0,
                    percent: 0.30,
                    center: new Text("30%"),
                    progressColor: Colors.orange,
                  ),
                  new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                  new CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 4.0,
                    percent: 0.60,
                    center: new Text("60%"),
                    progressColor: Colors.yellow,
                  ),
                  new Padding(padding: EdgeInsets.symmetric(horizontal: 10.0)),
                  new CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 4.0,
                    percent: 0.90,
                    center: new Text("90%"),
                    progressColor: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
