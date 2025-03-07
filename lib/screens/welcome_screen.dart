// import 'package:flutter/material.dart';
// import 'package:chat_app/screens/signin_screen.dart';
// import 'package:chat_app/screens/signup_screen.dart';
// import 'package:chat_app/theme/theme.dart';
// import 'package:chat_app/widgets/custom_scaffold.dart';
// import 'package:chat_app/widgets/welcome_button.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';


// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   _WelcomeScreenState createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<int> _textAnimation;
//   final String _text =
//       "Bienvenue sur Gerart !";

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 4),
//     );

//     _textAnimation = IntTween(begin: 0, end: _text.length).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );

//     _controller.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       child: Container(
       
//         child: Column(
//           children: [
//          Flexible(
//   flex: 1,
//   child: Stack(
//     children: [
//       // Conteneur principal avec une image de fond
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 40.0),
//         child: Center(
//           child: Column(
//             children: [
//               Spacer(flex: 100), // Espace flexible au-dessus
//               ShaderMask(
//                 shaderCallback: (bounds) => LinearGradient(
//                   colors: [Color(0xFFFFDB3D), Colors.blue],
//                   tileMode: TileMode.mirror,
//                 ).createShader(bounds),
//                 child: const Text(
//                   'GERART!',
//                   style: TextStyle(
//                     fontSize: 65.0,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                     fontFamily: 'Cinzel',
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 20), // Espace entre le titre et le texte animé
//               AnimatedTextKit(
//                 animatedTexts: [
//                   TypewriterAnimatedText(
//                     "Bienvenue sur Gerart !",
//                     textStyle: const TextStyle(
//                       fontSize: 20,
//                       color: Colors.white,
//                       fontFamily: 'Cinzel',
//                     ),
//                     speed: const Duration(milliseconds: 100),
//                   ),
//                 ],
//                 totalRepeatCount: 1,
//               ),
//               Spacer(flex: 1), // Espace flexible en dessous
//             ],
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

//             Flexible(
//               flex: 1,
//               child: Align(
//                 alignment: Alignment.bottomRight,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: WelcomeButton(
//                         buttonText: 'Connexion',
//                         onTap: SignInScreen(),
//                         color: Colors.transparent,
//                         textColor: Colors.white,
//                         icon: Icons.login, // Icône pour le bouton
//                       ),
//                     ),
//                     Expanded(
//                       child: WelcomeButton(
//                         buttonText: 'Inscription',
//                         onTap: const SignUpScreen(),
//                         color: Colors.white,
//                         textColor: lightColorScheme.primary,
//                         icon: Icons.person_add, // Icône pour le bouton
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class WelcomeButton extends StatelessWidget {
//   final String buttonText;
//   final Widget onTap;
//   final Color color;
//   final Color textColor;
//   final IconData? icon; // Nouveau paramètre optionnel pour l'icône

//   const WelcomeButton({
//     Key? key,
//     required this.buttonText,
//     required this.onTap,
//     required this.color,
//     required this.textColor,
//     this.icon, // Ajout du paramètre
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       icon: icon != null
//           ? Icon(icon, color: textColor)
//           : const SizedBox.shrink(), // Afficher l'icône uniquement si elle est définie
//       label: Text(
//         buttonText,
//         style: TextStyle(color: textColor),
//       ),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         padding: const EdgeInsets.symmetric(vertical: 16.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30.0),
//         ),
//       ),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => onTap),
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:chat_app/screens/signin_screen.dart';
import 'package:chat_app/screens/signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00292A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo et Nom
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png', // Assurez-vous d'ajouter cette image dans votre projet
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'GÉRART',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Image en arrière-plan
            Container(
              width: 300,
              height: 450,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/image.png'), // Assure-toi d'ajouter cette image dans ton projet
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bouton Créer un compte
            GestureDetector(
  onTap: () {
 // Ferme la boîte de dialogue
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  },
  child: const Text(
    'Créer un compte',
    style: TextStyle(
      fontSize: 18,
      color: Colors.white,
      decoration: TextDecoration.underline,
    ),
  ),
)
,
            const SizedBox(height: 15),

            // Bouton Se connecter
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDB3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () { // Ferme la boîte de dialogue
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );},
                child: const Text(
                  'Se connecter',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF00292A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
