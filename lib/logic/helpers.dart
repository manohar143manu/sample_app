import 'dart:convert';
import 'package:http/http.dart' as http;

class Helpers {
  Future<List<Map<String, dynamic>>> fetchRepositories() async {
    // Api call to fetch repositories
    final response = await http
        .get(Uri.parse("https://api.github.com/users/freeCodeCamp/repos"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load repositories');
    }
  }

  Future<Map<String, dynamic>> fetchLastCommit(
      String owner, String repo) async {
    final response = await http
        .get(Uri.parse("https://api.github.com/repos/$owner/$repo/commits"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first);
      } else {
        return {};
      }
    } else {
      throw Exception('Failed to load last commit for $repo');
    }
  }
}
