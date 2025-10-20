import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsApiService {
  // PUT YOUR API KEY HERE
  static const String _apiKey = '2f35ee13c0404660be0deb86ebe7e908';
  static const String _baseUrl = 'https://newsapi.org/v2';

  // Available categories
  static const List<String> availableCategories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
  ];

  // Available countries (optional)
  static const List<String> availableCountries = [
    'us', // United States
    'gb', // United Kingdom
    'ca', // Canada
    'au', // Australia
    'de', // Germany
  ];

  // Get top headlines by category
  Future<Map<String, dynamic>> getTopHeadlines({
    String category = 'general',
    String country = 'us',
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/top-headlines?country=$country&category=$category&pageSize=$pageSize&page=$page&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  // Search news articles
  Future<Map<String, dynamic>> searchNews({
    required String query,
    String sortBy = 'publishedAt', // publishedAt, relevancy, popularity
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/everything?q=$query&sortBy=$sortBy&pageSize=$pageSize&page=$page&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching news: $e');
    }
  }

  // Get news by multiple categories (for user's favorite categories)
  Future<Map<String, List<Map<String, dynamic>>>> getNewsByCategories({
    required List<String> categories,
    String country = 'us',
    int pageSize = 10,
  }) async {
    try {
      Map<String, List<Map<String, dynamic>>> categorizedNews = {};

      for (String category in categories) {
        final response = await getTopHeadlines(
          category: category,
          country: country,
          pageSize: pageSize,
        );

        if (response['status'] == 'ok') {
          categorizedNews[category] = List<Map<String, dynamic>>.from(
            response['articles'] ?? [],
          );
        }
      }

      return categorizedNews;
    } catch (e) {
      throw Exception('Error fetching categorized news: $e');
    }
  }

  // Get news from specific sources
  Future<Map<String, dynamic>> getNewsBySources({
    required List<String> sources,
    int pageSize = 20,
    int page = 1,
  }) async {
    try {
      final sourcesString = sources.join(',');
      final url = Uri.parse(
        '$_baseUrl/top-headlines?sources=$sourcesString&pageSize=$pageSize&page=$page&apiKey=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load news by sources: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news by sources: $e');
    }
  }

  // Get available news sources
  Future<Map<String, dynamic>> getSources({
    String? category,
    String? country,
  }) async {
    try {
      String queryParams = '';
      if (category != null) queryParams += '&category=$category';
      if (country != null) queryParams += '&country=$country';

      final url = Uri.parse(
        '$_baseUrl/sources?apiKey=$_apiKey$queryParams',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sources: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sources: $e');
    }
  }
}