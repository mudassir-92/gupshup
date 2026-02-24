import 'package:flutter/material.dart';

AppBar getAppBar(String ti){
  return AppBar(
    title: Text(ti),
    backgroundColor: Colors.lightBlueAccent,
    centerTitle: true,
  );
}