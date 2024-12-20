class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;  // Add imageUrl field
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl, // Initialize imageUrl
    this.quantity = 1,
  });
}

// Global list to manage cart items
List<CartItem> globalCartItems = [];
//AM
