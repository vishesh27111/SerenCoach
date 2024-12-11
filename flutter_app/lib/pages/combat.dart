import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_theme.dart';
import '../globals.dart' as globals; // Import globals

class Article {
  final String id;
  final String url;
  final String title;

  Article({required this.id, required this.url, required this.title});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'],
      url: json['url'],
      title: json['title'],
    );
  }
}

class ArticleListPage extends StatefulWidget {
  @override
  _ArticleListPageState createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  late Future<List<Article>> articles;

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse('${globals.api_base_url}/articles'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load articles');
    }
  }

  @override
  void initState() {
    super.initState();
    articles = fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Articles',
        ),
      ),
      body: FutureBuilder<List<Article>>(
        future: articles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      article.title,
                      style: theme.textTheme.headlineLarge!.copyWith(
                        fontSize: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    trailing: Icon(
                      Icons.open_in_new,
                      color: AppTheme.lightTheme.colorScheme.secondary,
                    ),
                    onTap: () async {
                      if (await canLaunch(article.url)) {
                        await launch(article.url);
                      } else {
                        throw 'Could not launch ${article.url}';
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
