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

  Future<List<BloodPressureReading>> getAllReadings() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('readings')
        .select()
        .eq('user_id', user.id)
        .order('measured_at', ascending: false);

    return response.map((json) => BloodPressureReading.fromJson(json)).toList();
  }

  Future<void> deleteReading(String id) async {
    await _client.from('readings').delete().eq('id', id);
  }
}
