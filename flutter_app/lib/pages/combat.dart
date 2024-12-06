import 'package:flutter/material.dart';
import '../service/NewsService.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePage extends StatefulWidget {
  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final NewsService newsService = NewsService();
  List articles = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  Future<void> loadArticles() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedArticles = await newsService.fetchMindfulnessArticles(page: page);
      setState(() {
        articles.addAll(fetchedArticles.where((article) => article['title'] != null && article['description'] != null));
        isLoading = false;
        hasMore = fetchedArticles.length == 20; // if fewer than 20 articles, end of pagination
        page++;
      });
    } catch (e) {
      print("Error loading articles: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading articles. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Combat Anxiety and Depression"),
      ),
      body: articles.isEmpty && !isLoading
          ? Center(child: Text("No articles found.", style: Theme.of(context).textTheme.bodyLarge))
          : ListView.builder(
        itemCount: articles.length + 1, // +1 for the "Load More" button
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return hasMore
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: loadArticles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Load More'),
              ),
            )
                : Container(); // No more articles to load
          }

          final article = articles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display image if available, else show a placeholder
                  if (article['urlToImage'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        article['urlToImage'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                        gradient: LinearGradient(
                          colors: [Colors.blueGrey.shade200, Colors.blueGrey.shade400],
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 50, color: Colors.white70),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['title'] ?? 'Untitled Article',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          article['description'] ?? 'No description available',
                          style: Theme.of(context).textTheme.bodyLarge,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article['source']['name'] ?? 'Unknown Source',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              article['publishedAt'] != null
                                  ? DateTime.parse(article['publishedAt']).toLocal().toString().split(' ')[0]
                                  : '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _launchURL(article['url']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text("Read More"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
