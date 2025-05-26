import 'package:flutter/material.dart';
import 'home_route.dart';
import 'home_view.dart';

/// A controller for the [HomeRoute] that manages the state and owns all business logic.
class HomeController extends State<HomeRoute> {
  @override
  Widget build(BuildContext context) => HomeView(this);
}
