import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paperless_mobile/core/service/connectivity_status_service.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityStatusService connectivityStatusService;
  StreamSubscription<bool>? _sub;

  ConnectivityCubit(this.connectivityStatusService)
      : super(ConnectivityState.undefined);

  Future<void> initialize() async {
    if (_sub == null) {
      final bool isConnected =
          await connectivityStatusService.isConnectedToInternet();
      emit(isConnected
          ? ConnectivityState.connected
          : ConnectivityState.notConnected);
      _sub =
          connectivityStatusService.connectivityChanges().listen((isConnected) {
        emit(isConnected
            ? ConnectivityState.connected
            : ConnectivityState.notConnected);
      });
    }
  }

  void reload() async {
    if (_sub == null) {
      initialize();
    } else {
      final bool isConnected =
          await connectivityStatusService.isConnectedToInternet();
      emit(isConnected
          ? ConnectivityState.connected
          : ConnectivityState.notConnected);
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

enum ConnectivityState {
  connected,
  notConnected,
  undefined;

  bool get isConnected => this == connected;
}
