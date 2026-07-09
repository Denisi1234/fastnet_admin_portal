import 'package:flutter/material.dart';
import 'package:admin_portal/theme/app_theme.dart';
import 'package:admin_portal/services/api_service.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? _drawerSelectedListing;
  List<Map<String, dynamic>> _listings = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchProperties();
    if (mounted) {
      setState(() {
        _listings = list.map<Map<String, dynamic>>((p) {
          final hostName = p['host'] != null ? p['host']['name'] : 'Unknown Host';
          final priceStr = p['price_per_night'] != null ? '\$${double.tryParse(p['price_per_night'].toString())?.toStringAsFixed(0) ?? p['price_per_night']}/night' : '\$100/night';
          final locationStr = p['address'] != null ? "${p['address']}, ${p['city']}" : p['city'] ?? 'Unknown Location';
          final imgUrl = p['image_url'] != null && p['image_url'].toString().isNotEmpty
              ? p['image_url']
              : 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=600&q=80';
          
          return {
            'id': p['id'],
            'title': p['name'] ?? 'Property',
            'host': hostName,
            'price': priceStr,
            'status': p['status'] ?? 'Active',
            'images': [imgUrl],
            'location': locationStr,
            'amenities': ['Wifi', 'AC', 'Kitchen'],
            'raw_property': p,
          };
        }).toList();

        if (_drawerSelectedListing != null) {
          final selectedId = _drawerSelectedListing!['id'];
          final found = _listings.firstWhere((l) => l['id'] == selectedId, orElse: () => {});
          if (found.isNotEmpty) {
            _drawerSelectedListing = found;
          }
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateListingStatus(Map<String, dynamic> listing, String newStatus) async {
    setState(() => _isLoading = true);
    final success = await ApiService.updatePropertyStatus(listing['id'], newStatus);
    if (success) {
      await _loadListings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${listing['title']} status is now $newStatus'),
          backgroundColor: newStatus == 'Active' ? AppTheme.success : AppTheme.danger,
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update property status.'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _showListingDetails(Map<String, dynamic> listing) {
    setState(() {
      _drawerSelectedListing = listing;
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final filteredListings = _listings.where((listing) {
      final titleMatches = listing['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final hostMatches = listing['host'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatches = listing['location'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final statusMatches = _statusFilter == 'All' || listing['status'] == _statusFilter;
      return (titleMatches || hostMatches || locationMatches) && statusMatches;
    }).toList();

    // Determine grid columns based on screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;
    if (screenWidth > 1400) {
      crossAxisCount = 4;
    } else if (screenWidth > 1000) {
      crossAxisCount = 3;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      endDrawer: _buildListingDetailsDrawer(),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property Listings',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Search & Filter Panel
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search properties by title, host or location...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      value: _statusFilter,
                      items: ['All', 'Active', 'Pending', 'Removed'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _statusFilter = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: filteredListings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'No properties match your filters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: filteredListings.length,
                      itemBuilder: (context, index) {
                        final listing = filteredListings[index];
                        return ListingCardWidget(
                          listing: listing,
                          onView: () => _showListingDetails(listing),
                          onAction: () => _updateListingStatus(
                            listing,
                            listing['status'] == 'Active' ? 'Removed' : 'Active',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingDetailsDrawer() {
    if (_drawerSelectedListing == null) return const Drawer();

    final listing = _drawerSelectedListing!;
    Color statusColor;
    switch (listing['status']) {
      case 'Active':
        statusColor = AppTheme.success;
        break;
      case 'Removed':
        statusColor = AppTheme.danger;
        break;
      default:
        statusColor = AppTheme.warning;
    }

    final List<dynamic> images = listing['images'] ?? [listing['image']];

    return Drawer(
      width: 450,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(32.0),
                children: [
                  // Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Property Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  // Property Cover Image (Interactive detail slider or PageView)
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PageView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, idx) {
                          return Image.network(
                            images[idx],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.surfaceHighlight,
                              child: const Icon(Icons.image_outlined, size: 48, color: AppTheme.border),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          listing['title'],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              listing['status'],
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location Address
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        listing['location'] ?? 'Unknown Location',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mock map layout widget
                  MockMapWidget(locationName: listing['location'] ?? 'Unknown Location'),
                  const SizedBox(height: 24),
                  // Host & Pricing Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Host Profile', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(listing['host'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHighlight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Price Quote', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(listing['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Amenities
                  const Text('Amenities & Offers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  if (listing['amenities'] != null && (listing['amenities'] as List).isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (listing['amenities'] as List<String>).map((amenity) {
                        return Chip(
                          label: Text(amenity, style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppTheme.surfaceHighlight,
                          side: const BorderSide(color: AppTheme.border),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        );
                      }).toList(),
                    )
                  else
                    const Text('No amenities declared.', style: TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic)),
                  const Divider(height: 48),
                  // Description
                  const Text('Property Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  const Text(
                    'This is a beautifully decorated property located in the heart of the city. Perfect for weekend getaways and long vacations alike. Contains 2 bedrooms, 1 bath, and a full kitchen.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),
            // Actions panel at bottom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: listing['status'] == 'Pending' || listing['status'] == 'Removed'
                        ? ElevatedButton(
                            onPressed: () {
                              _updateListingStatus(listing, 'Active');
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.textPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Approve Listing', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              _updateListingStatus(listing, 'Removed');
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.danger,
                              side: const BorderSide(color: AppTheme.danger),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Unlist Property', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListingCardWidget extends StatefulWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onView;
  final VoidCallback onAction;

  const ListingCardWidget({
    super.key,
    required this.listing,
    required this.onView,
    required this.onAction,
  });

  @override
  State<ListingCardWidget> createState() => _ListingCardWidgetState();
}

class _ListingCardWidgetState extends State<ListingCardWidget> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isHovered = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final List<dynamic> images = listing['images'] ?? [listing['image']];
    Color statusColor;
    switch (listing['status']) {
      case 'Active':
        statusColor = AppTheme.success;
        break;
      case 'Removed':
        statusColor = AppTheme.danger;
        break;
      default:
        statusColor = AppTheme.warning;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _isHovered ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.border),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel Area
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppTheme.surfaceHighlight,
                            child: const Center(
                              child: Icon(Icons.image_outlined, size: 48, color: AppTheme.border),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Left Chevron Arrow Overlay
                if (_isHovered && _currentImageIndex > 0)
                  Positioned(
                    left: 8,
                    top: 60,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        iconSize: 14,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                // Right Chevron Arrow Overlay
                if (_isHovered && _currentImageIndex < images.length - 1)
                  Positioned(
                    right: 8,
                    top: 60,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        iconSize: 14,
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  ),
                // Carousel dots overlay
                if (images.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (idx) {
                        final isCurrent = _currentImageIndex == idx;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isCurrent ? 7 : 5,
                          height: isCurrent ? 7 : 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.5),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
            // Listing Card details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing['title'],
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            listing['status'],
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Host: ${listing['host']}',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        listing['price'],
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: widget.onView,
                            style: TextButton.styleFrom(foregroundColor: AppTheme.textPrimary),
                            child: const Text('View', style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: widget.onAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: listing['status'] == 'Active' ? AppTheme.danger : AppTheme.textPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            child: Text(listing['status'] == 'Active' ? 'Unlist' : 'Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MockMapWidget extends StatelessWidget {
  final String locationName;
  const MockMapWidget({super.key, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 150),
                  painter: _MapPainter(),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_pin, color: AppTheme.primary, size: 36),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          locationName,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background fill (light beige map background)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF4F3F0),
    );

    // Draw a park (green area)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(30, 20, 100, 60),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFD4E7D0),
    );

    // Draw a river (blue line)
    final riverPaint = Paint()
      ..color = const Color(0xFFC4DDF2)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final riverPath = Path()
      ..moveTo(size.width - 20, -10)
      ..quadraticBezierTo(size.width - 100, size.height / 2, size.width - 40, size.height + 10);
    canvas.drawPath(riverPath, riverPaint);

    // Draw grid roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(-10, 40), Offset(size.width + 10, 50), roadPaint);
    canvas.drawLine(const Offset(-10, 110), Offset(size.width + 10, 100), roadPaint);
    canvas.drawLine(Offset(size.width / 2 - 40, -10), Offset(size.width / 2 - 20, size.height + 10), roadPaint);
    canvas.drawLine(Offset(size.width / 2 + 60, -10), Offset(size.width / 2 + 80, size.height + 10), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
