import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/product.dart';

class ProductCardV2 extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final String? saveAmount;
  final String? deliveryTime;

  const ProductCardV2({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.saveAmount,
    this.deliveryTime,
  });

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPrice != null
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;
    final saveAmountText =
        saveAmount ??
        (product.discountPrice != null
            ? 'Save ₹${(product.price - product.discountPrice!).toInt()}'
            : null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: product.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return const Icon(
                                Icons.image,
                                color: Colors.white70,
                                size: 40,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image,
                            color: Colors.white70,
                            size: 40,
                          ),
                  ),
                ),
                // Save Badge
                if (saveAmountText != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        saveAmountText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Discount Badge
                if (discount > 0 && saveAmountText == null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discount% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Heart Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Unit/Size
                    if (product.unit != null)
                      Text(
                        product.unit!,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (product.unit != null) const SizedBox(height: 1),
                    // Product Name
                    Flexible(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 1),
                    // Rating and Delivery Time
                    Row(
                      children: [
                        if (product.rating > 0) ...[
                          const Icon(Icons.star, color: Colors.amber, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 9,
                            ),
                          ),
                          if (product.reviewCount > 0) ...[
                            Text(
                              ' (${product.reviewCount})',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ],
                        if (deliveryTime != null && product.rating > 0)
                          Text(
                            ' • $deliveryTime',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Discount and Price
                    Row(
                      children: [
                        if (discount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '$discount% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (discount > 0) const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '₹${product.finalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (product.discountPrice != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        'MRP ₹${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    // Add Button
                    if (onAddToCart != null && product.isAvailable)
                      SizedBox(
                        width: double.infinity,
                        height: 24,
                        child: ElevatedButton(
                          onPressed: onAddToCart,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'ADD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
