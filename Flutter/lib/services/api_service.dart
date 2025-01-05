import 'package:dio/dio.dart';
import '../models/annoncemodel.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'http://10.0.2.2:8080/api'; //IP Local de la machine Hôte (URL API)

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<List<AnnonceModel>> getAllAnnonces() async {
    try {
      final response = await _dio.get('/annonces');
      return (response.data as List)
          .map((json) => AnnonceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnonceModel> getAnnonceById(int id) async {
    try {
      final response = await _dio.get('/annonces/$id');
      return AnnonceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnonceModel> createAnnonce(AnnonceModel annonce) async {
    try {
      final response = await _dio.post('/annonces', data: annonce.toJson());
      return AnnonceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AnnonceModel> updateAnnonce(int id, AnnonceModel annonce) async {
    try {
      final response = await _dio.put('/annonces/$id', data: annonce.toJson());
      return AnnonceModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAnnonce(int id) async {
    try {
      await _dio.delete('/annonces/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Connection timeout. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message =
              error.response?.data['message'] ?? 'Unknown error occurred';
          return ApiException(statusCode ?? 500, message);
        case DioExceptionType.cancel:
          return RequestCancelledException('Request was cancelled');
        default:
          return NetworkException('Network error occurred');
      }
    }
    return UnknownException('An unexpected error occurred');
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class RequestCancelledException implements Exception {
  final String message;
  RequestCancelledException(this.message);

  @override
  String toString() => 'RequestCancelledException: $message';
}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);

  @override
  String toString() => 'UnknownException: $message';
}
