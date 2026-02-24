import 'package:flutter_riverpod/legacy.dart';
import 'package:gupshup/models/call.dart';
import 'package:gupshup/screens/chat_tab_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final callsProvider =
    StateNotifierProvider.autoDispose<CallsNotifier, CallsState>((ref) {
      return CallsNotifier();
    });

class CallsNotifier extends StateNotifier<CallsState> {
  CallsNotifier() : super(CallsState(calls: [])) {
    initChannel();
  }
  Future<void> fetchCalls() async {
    final response = await Supabase.instance.client.rpc(
      'getuserforcallscreen',
      params: {'curr': currUser},
    );
    if (response.isNotEmpty) {
      List<Call> calls = [];
      response.map((call) => Call.fromMap(call)).toList().forEach((call) {
        calls.add(call);
      });
      state = state.copyWith(calls: calls);
    } else {
      // Handle error
      print('Error fetching calls}');
    }
  }

  final channel = Supabase.instance.client.channel('public:calls');
  void initChannel() {
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'calls',
      callback: (payload) async {
        print('New call record: ${payload.newRecord}');
        // jo id hai usko call model me convert kar do bro
        // payload id ko nikalo and run a custom function on supabase
        if (payload.newRecord['caller'] == currUser ||
            payload.newRecord['callee'] == currUser) {
          final newCallMap = await Supabase.instance.client
              .rpc('getcall', params: {'cid': payload.newRecord['id']})
              .single();
          print('newRecored');
          print(newCallMap);
          final newCall = Call.fromMap(newCallMap);
          state = state.copyWith(calls: [...state.calls, newCall]);
        }
      },
    );
    // channel.subscribe(); not subscribing handle it offline though
  }

  @override
  void dispose() {
    super.dispose();
    Supabase.instance.client.removeChannel(channel);
  }

  void addCall(Call c) {
    state = state.copyWith(calls: [c, ...state.calls]);
  }
}

class CallsState {
  final List<Call> calls;
  CallsState({required this.calls});
  CallsState copyWith({List<Call>? calls}) {
    return CallsState(calls: calls ?? this.calls);
  }
}
