import 'package:flutter/material.dart';

class RegionLocation extends StatelessWidget {
  const RegionLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 117, 117, 117)),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
      padding: const EdgeInsets.all(20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text("Current District :",
                  style: TextStyle(
                    color: Colors.black45,
                  )),
              Text("Lilongwe",
                  style: TextStyle(
                      color: Color.fromARGB(255, 27, 94, 32),
                      fontWeight: FontWeight.bold))
            ],
          ),
          VerticalDivider(
            color: Color.fromARGB(255, 0, 0, 0),
            thickness: 1,
            width: 20, // Adjust the width as needed
            indent: 5, // Adjust the indent as needed
            endIndent: 5, // Adjust the end indent as needed
          ),
          Column(
            children: [
              Text("Region :", style: TextStyle(color: Colors.black45)),
              Text("Central",
                  style: TextStyle(
                      color: Color.fromARGB(255, 27, 94, 32),
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
