import 'package:flutter/material.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({super.key});

  @override
  State<Dictionary> createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  // --- COLOR PALETTE ---
  // Using your specific green color directly in this file
  final Color fslPrimaryGreen = const Color(0xFF58C56E);

  // 1. Generate the alphabet list (a-z) automatically
  final List<String> _alphabet =
      List.generate(26, (index) => String.fromCharCode(97 + index));

  // This list holds the filtered results for the search bar
  List<String> _filteredAlphabet = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredAlphabet = _alphabet; // Start by showing all letters
  }

  // Logic to filter the list as the user types
  void _filterSearch(String query) {
    setState(() {
      _filteredAlphabet = _alphabet
          .where((letter) => letter.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // A simple function to show the image in a larger view (UX Requirement)
  void _showImageDialog(BuildContext context, String letter) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Letter ${letter.toUpperCase()}",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: fslPrimaryGreen), // Added color here too
              ),
            ),
            Container(
              height: 250,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                'assets/images/dictionary/$letter.jpg', // YOUR EXACT PATH
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: fslPrimaryGreen, // Button is now green
                  foregroundColor: Colors.white, // Text is white
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FSL Dictionary",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: fslPrimaryGreen, // Changed to your specific green
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Ensures back arrow is white
      ),
      body: Column(
        children: [
          // --- SEARCH BAR SECTION ---
          Container(
            color: fslPrimaryGreen, // Matches AppBar
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              cursorColor: fslPrimaryGreen,
              decoration: InputDecoration(
                hintText: "Search for a letter...",
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterSearch('');
                          FocusScope.of(context).unfocus(); // Hides keyboard
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- GRID VIEW SECTION ---
          Expanded(
            child: Container(
              color: Colors.grey[100], // Light background for contrast
              child: _filteredAlphabet.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 10),
                          Text("No letter found",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 16)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two cards per row
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85, // Adjusts height of the card
                      ),
                      itemCount: _filteredAlphabet.length,
                      itemBuilder: (context, index) {
                        String letter = _filteredAlphabet[index];

                        return GestureDetector(
                          onTap: () => _showImageDialog(context, letter),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                    ),
                                    child: Image.asset(
                                      'assets/images/dictionary/$letter.jpg',
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) =>
                                          const Icon(Icons.broken_image,
                                              size: 40, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: fslPrimaryGreen
                                        .withOpacity(0.1), // Light green bg
                                    borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(16)),
                                  ),
                                  child: Text(
                                    letter.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: fslPrimaryGreen, // Green text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
