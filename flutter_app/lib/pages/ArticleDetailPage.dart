import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ArticleDetailPage extends StatefulWidget {
  final String articleUrl;
  final String articleTitle;

  ArticleDetailPage({required this.articleUrl, required this.articleTitle});

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late WebViewController _webViewController;
  String extractedContent = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.articleUrl))
      ..runJavaScriptReturningResult('''
        (function() {
          const mainContent = document.querySelector('main') || document.body;
          const contentText = mainContent.innerText || '';
          return contentText.trim();
        })();
      ''').then((result) {
        if (result is String) {
          setState(() {
            extractedContent = result;
            isLoading = false;
          });
        } else {
          setState(() {
            extractedContent = 'Error: Failed to load content';
            isLoading = false;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.articleTitle),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _webViewController,
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  extractedContent,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}