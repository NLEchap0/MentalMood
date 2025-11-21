import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:mental_mood/DataBase/database.dart';
import 'package:mental_mood/Pages/UserSettingsPage/user_settings_page.dart';
import 'package:mental_mood/Pages/home_page.dart';

import 'EmotionSelectionPage/emotion_selection_page.dart';

class Menu extends StatelessWidget {
  final UtenteData? user;

  const Menu({super.key, required this.user});


  void _navigateToEmotionSelectionPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmotionSelectionPage(user: user),
      ),
    );
  }

  void _navigateToUserSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSettingsPage(user: user),
      ),
    );
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Container(
        height: 100,
        width: 400,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),

        ),
        child: Stack(
            children: [
              Center(
                child: LiquidGlassLayer(
                  settings: const LiquidGlassSettings(
                    thickness: 30,
                    blur: 3,
                    glassColor: Color(0x33FFFFFF),
                  ),
                  child: LiquidGlass(
                    shape: LiquidRoundedSuperellipse(
                      borderRadius: 50,
                    ),
                    child: SizedBox(
                      height: 100,
                      width: 400,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.only(left: 20.0),
                              onPressed: (){_navigateToHomePage(context);},
                              icon: Icon(Icons.home, size: 67, color: Colors.black,),
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  const CircleBorder(),
                                ),
                                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.zero,
                                ),
                                minimumSize: WidgetStateProperty.all<Size>(
                                  const Size(130, 100),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: (){_navigateToEmotionSelectionPage(context);},
                              icon: Icon(Icons.add, size: 67, color: Colors.black,),
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<OutlinedBorder>(
                                  const CircleBorder(),
                                ),
                                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.zero,
                                ),
                                minimumSize: WidgetStateProperty.all<Size>(
                                  const Size(130, 100),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 35,right: 20.0),
                              child: InkWell(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    user!.username[0],
                                    style: TextStyle(fontSize: 40, color: Colors.white),
                                  ),
                                ),
                                onTap: () {_navigateToUserSettingsPage(context);},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ]
        ),
      )
    );
  }
}
