import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final Future<String> apiCall;

  const StatCard({
    super.key,
    required this.title,
    required this.apiCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13, 
              color: Color(0xFF0A0A0A), 
            ),
          ),
          
          const SizedBox(height: 12),
          
          FutureBuilder<String>(
            future: apiCall, 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 20, 
                  width: 20, 
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF3E5F44),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return const Text('!', style: TextStyle(color: Colors.red, fontSize: 24));
              }
              
              return Text(
                snapshot.data ?? '-',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF3E5F44), 
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}