import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

PreferredSizeWidget customAppBar({
  required Widget title,
  required Widget peerAvatarUrl,
  required VoidCallback onAvatarTap,
  required VoidCallback onPhoneTap,
  required Status status,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100), // Set your desired app bar height here
    child: SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.transparent,
        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(

              children: [

                GestureDetector(
                  onTap: onAvatarTap,
                  child: peerAvatarUrl,
                ),

                const SizedBox(width: 10,),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    title,
                    const SizedBox(height: 10,),

                    // const Text('Online', style: TextStyle(
                    //   color: Colors.white
                    // ),)

                  // FutureBuilder<bool>(
                  //   future: status,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //
                  //       return const Text('Loading...');
                  //
                  //     } else if (snapshot.hasError) {
                  //
                  //       return const Text('Error');
                  //
                  //     } else {
                  //
                  //      // final boolValue = snapshot.data ?? false; // Use a default value in case of null data
                  //
                  //       if (snapshot.data == true) {
                  //         return const Text('True');
                  //
                  //       } else {
                  //         return const Text('False');
                  //       }
                  //     }
                  //   },
                  // ),

                    status == Status.uninitialized?
                        const SizedBox.shrink()
                        : const Text('Online'),

              ],
                ),
              ],

            ),

            const SizedBox(width: 10,),


            Row(

              children: [

                IconButton(
                  onPressed: onPhoneTap,
                  icon: const Icon(Icons.phone, color: Colors.white,),
                ),

                IconButton(
                  onPressed: onPhoneTap,
                  icon: const Icon(Icons.video_call, color: Colors.white),
                ),

              ],
            )
          ],
        ),
      ),
    ),
  );
}
