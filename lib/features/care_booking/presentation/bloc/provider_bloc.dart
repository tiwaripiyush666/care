import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/provider_repository.dart';

// --- Events ---
abstract class ProviderEvent {}

class LoadProviders extends ProviderEvent {
  final String? query;
  final String? serviceType;
  LoadProviders({this.query, this.serviceType});
}

// --- States ---
abstract class ProviderState {}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProviderLoaded extends ProviderState {
  final List<Map<String, dynamic>> providers;
  ProviderLoaded(this.providers);
}

class ProviderError extends ProviderState {
  final String message;
  ProviderError(this.message);
}

// --- Bloc ---
class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final ProviderRepository providerRepository;

  ProviderBloc({required this.providerRepository}) : super(ProviderInitial()) {
    on<LoadProviders>(_onLoadProviders);
  }

  Future<void> _onLoadProviders(LoadProviders event, Emitter<ProviderState> emit) async {
    emit(ProviderLoading());
    try {
      final providers = await providerRepository.fetchProviders(
        query: event.query,
        serviceType: event.serviceType,
      );
      emit(ProviderLoaded(providers));
    } catch (e) {
      emit(ProviderError(e.toString()));
    }
  }
}
