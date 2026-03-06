import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';
import 'package:medgurdian/core/widgets/DraggableAssistiveTouch.dart';
import 'package:medgurdian/modules/cancer_detection/bloc/scan_bloc.dart';
import 'package:medgurdian/modules/cancer_detection/pages/ScanScreen.dart';
import 'package:medgurdian/modules/chat/pages/MedicalChatScreen.dart';
import 'package:medgurdian/modules/profile/pages/ProfileScreen.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const Center(
      child: Text(
        "Home",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    MedicalChatScreen(),
    const Center(
      child: Text(
        "Records",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/logo/MedGLogo.png"),
              width: 30,
              height: 30,
              fit: BoxFit.fill,
            ),
            const Text(
              "MedGuardian",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: Stack(children: [screens[currentIndex],DraggableAssistiveTouch(onTap: (){
        Navigator.pushNamed(context, RouteName.MedicalChat);
      })]),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (routeContext) => BlocProvider<ScanBloc>(
                create: (context) => ScanBloc(),
                child: const ScanScreen(),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.document_scanner,
          color: Colors.white,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabItem(index: 0, icon: Icons.home, label: "Home"),
                  _buildTabItem(
                    index: 1,
                    icon: Icons.smart_toy,
                    label: "Schedule",
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabItem(
                    index: 2,
                    icon: Icons.medical_information,
                    label: "Records",
                  ),
                  _buildTabItem(index: 3, icon: Icons.person, label: "Profile"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: currentIndex == index ? Colors.blue : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.blue : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
