import 'package:flutter/material.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  final Color fslPrimaryGreen = const Color(0xFF58C56E);
  final Color bgGrey = const Color(0xFFF5F7FA);

  final List<String> _alphabet =
      List.generate(26, (index) => String.fromCharCode(97 + index));

  List<String> _filteredAlphabet = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredAlphabet = _alphabet;
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredAlphabet = _alphabet
          .where((letter) => letter.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // --- UPGRADE 1: "Focus" Dialog ---
  // Removed clutter, maximized image size.
  void _showImageDialog(BuildContext context, String letter) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87, // Darker background for focus
        pageBuilder: (context, _, __) {
          return Center(
            child: Hero(
              tag: 'hero-letter-$letter',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  // Allowed to take up more vertical space
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 2)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clean Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Letter ${letter.toUpperCase()}",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // Circle Close Button
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  color: Colors.black54),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // MAXIMIZED IMAGE
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: fslPrimaryGreen.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/dictionary/$letter.jpg',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => Icon(
                                Icons.broken_image_rounded,
                                size: 60,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Helpful Tip instead of Big Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app,
                              size: 16, color: fslPrimaryGreen),
                          const SizedBox(width: 8),
                          Text(
                            "Practice mirroring this sign",
                            style: TextStyle(
                                color: fslPrimaryGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: bgGrey,
      appBar: AppBar(
        title: const Text("FSL Dictionary",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: fslPrimaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Search Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            decoration: BoxDecoration(
                color: fslPrimaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: fslPrimaryGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Search a letter...",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: fslPrimaryGreen),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterSearch('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // Results Count (Nice Feedback)
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 10),
                    child: Text(
                      "Found ${_filteredAlphabet.length} result(s)",
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12),
                    ),
                  )
              ],
            ),
          ),

          Expanded(
            child: _filteredAlphabet.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio:
                          0.85, // Slightly taller for better proportions
                    ),
                    itemCount: _filteredAlphabet.length,
                    itemBuilder: (context, index) {
                      String letter = _filteredAlphabet[index];
                      return _buildFlashcard(context, letter);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- UPGRADE 2: "Polaroid" Style Card ---
  Widget _buildFlashcard(BuildContext context, String letter) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, letter),
      child: Hero(
        tag: 'hero-letter-$letter',
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Stack(
              children: [
                // 1. The Image (Centered & Large)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset(
                      'assets/images/dictionary/$letter.jpg',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image_rounded,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),

                // 2. The Badge (Clean, Modern, Top Right)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: fslPrimaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        letter.toUpperCase(),
                        style: TextStyle(
                          color: fslPrimaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Subtle "View" Icon (Bottom Right)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Icon(
                    Icons.zoom_in_rounded,
                    color: Colors.grey.shade300,
                    size: 20,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 60, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            Text(
              "No letter found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
