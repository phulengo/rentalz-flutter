import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          "assets/images/logo/120x120.png",
          width: 60,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          "RentalZ",
          style: Theme.of(context).textTheme.headline5,
        )
      ],
    );
  }
}
