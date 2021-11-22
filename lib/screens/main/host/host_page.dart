import 'package:flutter/material.dart';
import 'package:rentalz_flutter/widgets/host_form.dart';

class HostPage extends StatefulWidget {
  const HostPage({Key? key}) : super(key: key);

  @override
  _HostPageState createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "List your spaces",
          style: Theme.of(context).textTheme.headline6,
        ),
        const Padding(
          padding: EdgeInsets.only(top: 24.0),
          child: HostForm(),
        )
      ],
    );
  }
}
