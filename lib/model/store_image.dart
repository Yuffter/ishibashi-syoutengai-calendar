import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

class StoreImageModel {
  final String id;
  final String imageUrl;

  StoreImageModel({required this.id, required this.imageUrl});
}