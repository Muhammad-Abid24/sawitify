import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaylist extends StatelessWidget {
  final bool isTablet;

  const ShimmerPlaylist({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Column(
        children: [

          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32 : 20,
              vertical: 4,
            ),

            leading: Container(
              width: isTablet ? 70 : 50,
              height: isTablet ? 70 : 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(5),
              ),
            ),

            title: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(4),
              ),
            ),

            subtitle: Padding(
              padding:
              const EdgeInsets.only(top: 8),
              child: Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(4),
                ),
              ),
            ),

            trailing: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: isTablet ? 118 : 92,
              right: 20,
            ),
            child: Divider(
              height: 1,
              thickness: .1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}