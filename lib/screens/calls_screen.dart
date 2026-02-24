import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gupshup/Controller/calls_provider.dart';
import 'package:gupshup/screens/chat_tab_screen.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  Future<void> loadCalls() async {
    print('loading calls bro');
    await ref.read(callsProvider.notifier).fetchCalls();
  }

  @override
  void initState() {
    super.initState();
    // fetch calls bro
    // context.read(callsProvider.notifier).fetchCalls()
    // use ref to use the provider bro
    loadCalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: ref.watch(callsProvider).calls.length,
          itemBuilder: (context, index) {
            final call = ref.watch(callsProvider).calls[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading:call.callerId==currUser?Icon(Icons.call_made_outlined, color: Colors.green):Icon(Icons.call_received_outlined, color: Colors.red),
                title: call.callerId==currUser?Text(call.callee):Text(call.caller),
                trailing: call.type == 'video'
                    ? Icon(Icons.videocam_outlined)
                    : Icon(Icons.call_outlined),
                subtitle: Text(call.timestamp),
              ),
            );
          },
        ),
      ),
    );
  }
}
