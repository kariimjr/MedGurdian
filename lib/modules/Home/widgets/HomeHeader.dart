import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.blue.shade800,

      flexibleSpace: FlexibleSpaceBar(
        // 1. Move Name to the very bottom
        titlePadding: const EdgeInsets.only(left: 20, bottom: 8),
        centerTitle: false,
        expandedTitleScale: 1.4,

        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$greeting,",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16, // Base size (will scale up when expanded)
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20, // Base size
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
              // 2. Position the Quote Card ABOVE the name
              // We use top: 60 to keep it near the top of the blue area
              Positioned(
                top: 70,
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