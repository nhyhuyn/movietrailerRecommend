// ignore_for_file: missing_required_param

import 'package:flutter/material.dart';
import 'package:movie_app/Screens/DetailsPage/Components/DetailPageBody.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: DetailsPageBody());
  }
}
