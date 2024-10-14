import 'package:flutter/material.dart';
import 'package:neurossistant/src/pages/consult/consult.dart';

class ParentProfile extends StatefulWidget {
  final Pengguna pengguna;
  const ParentProfile({super.key, required this.pengguna});

  @override
  State<ParentProfile> createState() => _ParentProfileState();
}

class _ParentProfileState extends State<ParentProfile> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 25),
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(80),
                    onTap: () {
                      // ke profil pengguna yang ditekan
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.pengguna.profilPicture),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const SizedBox(
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                ),
              ); // display the user's profile picture
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              widget.pengguna.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       ElevatedButton(
          //           onPressed: () {},
          //           style: ButtonStyle(
          //               foregroundColor: MaterialStateProperty.all<Color>(
          //                   ThemeClass().lightPrimaryColor),
          //               backgroundColor: MaterialStateProperty.all<Color>(
          //                   isDarkMode
          //                       ? ThemeClass().darkPrimaryColor
          //                       : Colors.white),
          //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                   RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(25),
          //                       side: BorderSide(
          //                           color: ThemeClass().lightPrimaryColor,
          //                           width: 2))),
          //               minimumSize:
          //                   MaterialStateProperty.all<Size>(const Size(160, 60))),
          //           child: const Text(
          //             "Chat",
          //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //           )),
          //       const SizedBox(
          //         width: 12,
          //       ),
          //       ElevatedButton(
          //           onPressed: _datePick,
          //           style: ButtonStyle(
          //               foregroundColor:
          //                   MaterialStateProperty.all<Color>(Colors.white),
          //               backgroundColor: MaterialStateProperty.all<Color>(
          //                   ThemeClass().lightPrimaryColor),
          //               shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //                   RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(25),
          //                       side: BorderSide(
          //                           color: ThemeClass().lightPrimaryColor))),
          //               minimumSize:
          //                   MaterialStateProperty.all<Size>(const Size(160, 60))),
          //           child: const Text(
          //             "Make Appointment",
          //             style: TextStyle(
          //               fontSize: 18,
          //             ),
          //             textAlign: TextAlign.center,
          //           )),
          //     ],
          //   ),
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 15),
          //     child: Divider(
          //       color: isDarkMode
          //           ? Colors.white
          //           : const Color.fromARGB(255, 75, 74, 74),
          //       thickness: 0.7,
          //     ),
          //   ),
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(30, 10, 30, 0),
          //     child: Container(
          //       // constraints: BoxConstraints(minHeight: 400),
          //       width: MediaQuery.of(context).size.width,
          //       decoration: BoxDecoration(
          //         color: isDarkMode
          //             ? const Color.fromARGB(255, 41, 41, 41)
          //             : Color.fromARGB(255, 230, 230, 230),
          //         borderRadius: BorderRadius.circular(6),
          //         boxShadow: [
          //           BoxShadow(
          //             color: isDarkMode
          //                 ? Colors.transparent
          //                 : const Color.fromARGB(255, 74, 74, 74),
          //             blurRadius: 6,
          //             spreadRadius: 0,
          //             offset: const Offset(0, 2), // Shadow position
          //           ),
          //         ],
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.all(14),
          //         child: Column(
          //           mainAxisSize: MainAxisSize.max,
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Experience",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "4 Tahun",
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                     // overflow: TextOverflow.ellipsis,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Educational Background",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "S2 Psikologi Universitas Sriwijaya",
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Practice Place",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "Rumah Sakit Umum Palembang",
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Domicile",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "Palembang",
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Consultation Fee",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "Rp.0—Rp.1.000.000",
          //                     style: TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 10),
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               mainAxisSize: MainAxisSize.max,
          //               children: [
          //                 Flexible(
          //                   child: Text(
          //                     "Consultation Fee",
          //                     style: TextStyle(
          //                         fontSize: 16,
          //                         color: isDarkMode
          //                             ? Colors.grey[300]
          //                             : Colors.grey[900]),
          //                   ),
          //                 ),
          //                 Flexible(
          //                   child: Text(
          //                     "⭐${widget.pengguna.rating} | 0 reviews",
          //                     style: const TextStyle(
          //                         fontSize: 16, fontWeight: FontWeight.w500),
          //                     textAlign: TextAlign.right,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             const SizedBox(height: 5),
          //           ],
          //         ),
          //       ),
          //     ),
          //   )
        ],
      ),
    );
  }
}
