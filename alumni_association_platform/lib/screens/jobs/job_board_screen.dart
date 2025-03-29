import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/job_model.dart';
import '../../services/firebase_service.dart';
import 'job_detail_screen.dart';

class JobBoardScreen extends StatelessWidget {
  const JobBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Job Board')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/jobs/create'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseService.firestore
          .collection('jobs')
          .orderBy('createdAt', descending: true)
          .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data!.docs.map((doc) => 
            JobModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
          ).toList();

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(job.title),
                  subtitle: Text(job.company),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(job: job),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}