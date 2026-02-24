import 'package:flutter/material.dart';
import 'package:gupshup/screens/profile_screen.dart';
import 'package:gupshup/screens/chat_tab_screen.dart';
import 'package:gupshup/screens/calls_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Widget buildChatScreen() {
  return Column(children: [Text('1')]);
}

Widget buildStatusScreen() {
  return Column(children: [Text('2')]);
}

Widget buildProfileScreen() {
  return Column(children: [Text('3')]);
}

class _HomeScreenState extends State<HomeScreen> {
  int currIdx = 0;
  List<Widget> screens = [ChatTabScreen(), CallsScreen(), ProfileScreen()];
  // Future<void> bro() async {}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gupshup'),
        // backgroundColor: Colors,
        backgroundColor: Colors.purple[50],
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: currIdx,
        onTap: (idx) {
          setState(() {
            currIdx = idx;
          });
        },
        backgroundColor: Colors.purple[50],
        curve: Curves.easeInOut,
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.chat),
            title: Text('Chats'),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.call_outlined),
            title: Text('Calls'),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.people_alt_sharp),
            title: Text('Profile'),
            selectedColor: Colors.green,
          ),
        ],
      ),
      body: IndexedStack(index: currIdx, children: screens),
      drawer: NavigationDrawer(
        children: [
          GestureDetector(
            onTap: () {
              Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: ListTile(title: Text("LOGOUT")),
          ),
        ],
      ),
    );
  }
}
