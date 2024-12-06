import 'dart:convert';
import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class NewsService {

  Future<List<dynamic>> fetchMindfulnessArticles({int page = 1}) async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=mindfulness OR meditation OR well-being OR anxiety OR depression OR stress OR therapy&apiKey=${globals.news_api_key}&pageSize=20&page=$page',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
