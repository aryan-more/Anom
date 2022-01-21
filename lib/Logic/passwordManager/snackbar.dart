import 'package:flutter/material.dart';

void showSnackBar({required BuildContext context, required String error}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error,
            color: Colors.white,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            error,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    ),
  );
}
