import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/trending_story.dart';

class TrendingStoryService {
  final _storage = GetStorage();

  Map<String, String> _headers({bool auth = false}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final token = _storage.read('token');
    if (auth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<TrendingStoryPage> fetchStories({
    int page = 1,
    int perPage = 10,
    String? search,
    String? category,
  }) async {
    final query = <String, String>{'page': '$page', 'per_page': '$perPage'};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (category != null && category.isNotEmpty) query['category'] = category;

    final uri = Uri.parse('${apiurl}v1/trending-stories').replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode != 200) throw Exception('Failed to load trending stories');

    final body = json.decode(response.body);
    final rawStories = body['trending_stories'];
    final list = rawStories is Map ? (rawStories['data'] as List? ?? []) : (rawStories as List? ?? []);
    final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

    return TrendingStoryPage(
      stories: list.map((e) => TrendingStory.fromJson(e)).toList(),
      currentPage: pagination['current_page'] ?? page,
      lastPage: pagination['last_page'] ?? 1,
      hasMore: pagination['has_more'] == true,
    );
  }

  Future<TrendingExploreData> fetchExplore() async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/trending-stories/explore'),
      headers: _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to load explore');

    final body = json.decode(response.body);
    return TrendingExploreData(
      categories: (body['categories'] as List? ?? []).map((e) => TrendingCategory.fromJson(e)).toList(),
      forYou: (body['for_you'] as List? ?? []).map((e) => TrendingStory.fromJson(e)).toList(),
      featured: (body['featured'] as List? ?? []).map((e) => TrendingStory.fromJson(e)).toList(),
      publisher: TrendingPublisher.fromJson(body['publisher'] ?? {}),
    );
  }

  Future<Map<String, dynamic>> fetchStoryDetail(String id) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/trending-stories/$id'),
      headers: _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to load trending story');

    final body = json.decode(response.body);
    return {
      'story': TrendingStory.fromJson(body['trending_story']),
      'related': (body['related_stories'] as List? ?? []).map((e) => TrendingStory.fromJson(e)).toList(),
    };
  }

  Future<TrendingStoryPage> fetchPublisherStories({int page = 1}) async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/trending-stories/publisher/stories?page=$page&per_page=12'),
      headers: _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to load publisher stories');

    final body = json.decode(response.body);
    final list = body['stories'] is Map ? (body['stories']['data'] as List? ?? []) : (body['stories'] as List? ?? []);
    final pagination = body['pagination'] as Map<String, dynamic>? ?? {};

    return TrendingStoryPage(
      stories: list.map((e) => TrendingStory.fromJson(e)).toList(),
      currentPage: pagination['current_page'] ?? page,
      lastPage: pagination['last_page'] ?? 1,
      hasMore: pagination['has_more'] == true,
    );
  }

  Future<TrendingPublisher> fetchPublisher() async {
    final response = await http.get(
      Uri.parse('${apiurl}v1/trending-stories/publisher'),
      headers: _headers(),
    );
    if (response.statusCode != 200) throw Exception('Failed to load publisher');
    return TrendingPublisher.fromJson(json.decode(response.body)['publisher']);
  }

  Future<Map<String, dynamic>> toggleLike(String id) async {
    final response = await http.post(
      Uri.parse('${apiurl}v1/trending-stories/$id/like'),
      headers: _headers(auth: true),
    );
    if (response.statusCode == 401) throw Exception('login_required');
    if (response.statusCode != 200) throw Exception('Failed to like story');
    return json.decode(response.body) as Map<String, dynamic>;
  }

  Future<bool> toggleBookmark(String id) async {
    final response = await http.post(
      Uri.parse('${apiurl}v1/trending-stories/$id/bookmark'),
      headers: _headers(auth: true),
    );
    if (response.statusCode == 401) throw Exception('login_required');
    if (response.statusCode != 200) throw Exception('Failed to bookmark story');
    return json.decode(response.body)['is_bookmarked'] == true;
  }
}
