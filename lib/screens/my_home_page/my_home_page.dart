// my_home_page

import 'package:flutter/material.dart';
import 'package:sample_app/logic/helpers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Map<String, dynamic>>> _repositories;

  Helpers helpers = Helpers();

  @override
  void initState() {
    super.initState();
    _repositories = helpers.fetchRepositories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Github Repositories'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _repositories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var repo = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: ListTile(
                        title: Text(repo['name']),
                        subtitle: Text(
                            repo['description'] ?? 'No description available'),
                        onTap: () async {
                          try {
                            var lastCommit = await helpers.fetchLastCommit(
                                repo['owner']['login'], repo['name']);
                            // Show last commit information if dialog is not already open
                            if (!Navigator.of(context).canPop()) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title:
                                        Text('Last Commit for ${repo['name']}'),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            'Message: ${lastCommit['commit']['message'] ?? 'No message available'}'),
                                        const SizedBox(height: 8),
                                        Text(
                                            'Author: ${lastCommit['commit']['author']['name'] ?? 'Unknown'}'),
                                        const SizedBox(height: 8),
                                        Text(
                                            'Date: ${lastCommit['commit']['author']['date'] ?? 'Unknown'}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Colors.blue.shade300,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } catch (e) {
                            // Handle error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to load last commit for ${repo['name']}'),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
