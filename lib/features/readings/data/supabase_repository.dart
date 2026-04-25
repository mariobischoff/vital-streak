import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/blood_pressure_reading.dart';

final supabaseRepositoryProvider = Provider<SupabaseRepository>((ref) {
  return SupabaseRepository(Supabase.instance.client);
});

class SupabaseRepository {
  final SupabaseClient _client;

  SupabaseRepository(this._client);

  Future<void> saveReading(BloodPressureReading reading) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    reading.userId = user.id;
    await _client.from('readings').insert(reading.toJson());
  }

  Future<List<BloodPressureReading>> getAllReadings({int? limit, int? offset}) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    var query = _client
        .from('readings')
        .select()
        .eq('user_id', user.id)
        .order('measured_at', ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      // Supabase range is inclusive
      query = query.range(offset, offset + (limit ?? 10) - 1);
    }

    final response = await query;

    return response.map((json) => BloodPressureReading.fromJson(json)).toList();
  }

  Future<void> deleteReading(String id) async {
    await _client.from('readings').delete().eq('id', id);
  }
}
