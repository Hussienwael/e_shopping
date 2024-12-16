class Transaction {
    final String userId;
    final DateTime orderDate;
    final List<Map<String, dynamic>> products;
    final double totalAmount;
    final String status;

    Transaction({
        required this.userId,
        required this.orderDate,
        required this.products,
        required this.totalAmount,
        required this.status,
    });
}
