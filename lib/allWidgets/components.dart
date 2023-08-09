// Container
// ( // Profile image
// clipBehavior: Clip.hardEdge,
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(Sizes.dimen_20),
// ),
// child: Image.network(
// widget.peerAvatar,
// width: Sizes.dimen_40,
// height: Sizes.dimen_40,
// fit: BoxFit.cover,
// loadingBuilder: (BuildContext ctx, Widget child,
// ImageChunkEvent? loadingProgress) {
// if (loadingProgress == null) return child;
// return Center(
// child: CircularProgressIndicator(
// color: AppColors.burgundy,
// value: loadingProgress.expectedTotalBytes !=
// null &&
// loadingProgress.expectedTotalBytes !=
// null
// ? loadingProgress.cumulativeBytesLoaded /
// loadingProgress.expectedTotalBytes!
//     : null,
// ),
// );
// },
// errorBuilder: (context, object, stackTrace) {
// return const Icon(
// Icons.account_circle,
// size: 35,
// color: AppColors.greyColor,
// );
// },
// )
// ,




// )
//
//
