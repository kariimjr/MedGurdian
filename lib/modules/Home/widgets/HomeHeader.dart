import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final String userName;
  final String quote;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.userName,
    required this.quote,
  });

  Future<void> _makeEmergencyCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '123',
    );
    try {
      await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      debugPrint("Dialer process initialized successfully.");
    } catch (e) {
      debugPrint("Could not open dialer protocol forcefully: $e");
      try {
        final String telUrl = 'tel:123';
        await launchUrl(Uri.parse(telUrl), mode: LaunchMode.externalApplication);
      } catch (nestedErr) {
        debugPrint("All system launching overrides exhausted: $nestedErr");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.blue.shade800,
      // 🟢 REMOVED global actions bar implementation so button can transition dynamically

      flexibleSpace: FlexibleSpaceBar(
        // 🎯 Adjusted right padding to guarantee safety layout margins for the inline chip
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        centerTitle: false,
        expandedTitleScale: 1.25, // 🎯 Optimizing scale multiplier avoids rendering clipping at peak layout compression

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 👤 LEFT SIDE: User Identity Column Layout
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$greeting,",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13, // Base scalable size metrics layout mapping
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          userName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17, // Optimized fallback scale base sizing
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "👋",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🚨 RIGHT SIDE: Dynamic SOS Button synced with the title rendering loop
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: SizedBox(
                height: 28, // 🎯 Restrained structural height prevents app bar overflow constraints when collapsed
                child: ElevatedButton.icon(
                  onPressed: _makeEmergencyCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black45,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    // ⚠️ Scaled size elements adjust text inside the flexible container cleanly
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.gpp_maybe_rounded, color: Colors.white, size: 12),
                  label: const Text(
                    "SOS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10, // 🎯 Balanced font scale moves seamlessly inside the text engine
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 65,
                left: 20,
                right: 20,
                child: _buildQuoteCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: Colors.white54, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}