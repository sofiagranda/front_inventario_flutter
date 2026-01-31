/// Clase genérica para manejar respuestas paginadas del backend (Django Rest Framework)
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  /// Factory para convertir el JSON de la API en una instancia de PaginatedResponse.
  /// [json] es el mapa que devuelve Dio (response.data).
  /// [mapper] es una función que convierte cada elemento de la lista 'results' en el objeto tipo T.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return PaginatedResponse<T>(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => mapper(item as Map<String, dynamic>))
          .toList(),
    );
  }
}