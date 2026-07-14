abstract class ProviderRepository {
  Future<List<Map<String, dynamic>>> fetchProviders({
    String? query,
    String? serviceType,
  });
}
