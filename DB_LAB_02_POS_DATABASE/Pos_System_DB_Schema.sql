-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 03, 2026 at 05:56 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- ============================================================
--  CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS `pos_system`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE `pos_system`;

--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_name`, `description`) VALUES
(1, 'Electronics', 'Electronic devices, computers, and accessories'),
(2, 'Clothing', 'Apparel, fashion items, and accessories'),
(3, 'Sports & Outdoors', 'Sports equipment and outdoor gear'),
(4, 'Home & Kitchen', 'Home appliances and kitchen items'),
(5, 'Books & Media', 'Books, magazines, and media products'),
(6, 'Toys & Games', 'Children toys, board games, and educational items'),
(7, 'Health & Beauty', 'Personal care, skincare, and wellness products'),
(8, 'Groceries', 'Food, beverages, and daily consumables'),
(9, 'Stationery', 'Office supplies, notebooks, and writing instruments'),
(10, 'Furniture', 'Indoor and outdoor furniture and decor');

-- --------------------------------------------------------

--
-- Table structure for table `discounts`
--

CREATE TABLE `discounts` (
  `discount_id` int(11) NOT NULL,
  `discount_code` varchar(20) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `discount_type` enum('percentage','fixed') NOT NULL DEFAULT 'percentage',
  `discount_value` decimal(10,2) NOT NULL COMMENT 'Percentage (0-100) or fixed PKR/USD amount',
  `min_order_amount` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Minimum cart total to apply this discount',
  `product_id` int(11) DEFAULT NULL COMMENT 'NULL = applies to all products',
  `category_id` int(11) DEFAULT NULL COMMENT 'NULL = applies to all categories',
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `discounts`
--

INSERT INTO `discounts` (`discount_id`, `discount_code`, `description`, `discount_type`, `discount_value`, `min_order_amount`, `product_id`, `category_id`, `start_date`, `end_date`, `is_active`, `created_at`) VALUES
(1, 'WELCOME10', 'New customer welcome offer — 10% off', 'percentage', 10.00, 0.00, NULL, NULL, '2026-01-01', '2026-12-31', 1, '2026-05-03 15:55:25'),
(2, 'SUMMER20', 'Summer sale — 20% off all clothing', 'percentage', 20.00, 50.00, NULL, 2, '2026-06-01', '2026-08-31', 1, '2026-05-03 15:55:25'),
(3, 'TECH50', 'Fixed Rs.50 off on any electronics purchase', 'fixed', 50.00, 200.00, NULL, 1, '2026-01-01', '2026-03-31', 1, '2026-05-03 15:55:25'),
(4, 'FLASH15', 'Flash sale — 15% off sitewide for 48 hours', 'percentage', 15.00, 0.00, NULL, NULL, '2026-02-14', '2026-02-16', 0, '2026-05-03 15:55:25'),
(5, 'IPHONE5', 'Rs.5 off on iPhone 15 Pro — limited time', 'fixed', 5.00, 999.99, 1, NULL, '2026-02-01', '2026-02-28', 0, '2026-05-03 15:55:25'),
(6, 'SPORTS25', '25% off sports & outdoor products', 'percentage', 25.00, 30.00, NULL, 3, '2026-03-01', '2026-05-31', 1, '2026-05-03 15:55:25'),
(7, 'FREESHIP', 'Free shipping equivalent — Rs.30 fixed discount', 'fixed', 30.00, 100.00, NULL, NULL, '2026-01-01', '2026-12-31', 1, '2026-05-03 15:55:25'),
(8, 'EID2026', 'Eid special — 18% off on home & kitchen', 'percentage', 18.00, 75.00, NULL, 4, '2026-03-28', '2026-04-05', 1, '2026-05-03 15:55:25'),
(9, 'BOOK10', '10% off on all books and media', 'percentage', 10.00, 0.00, NULL, 5, '2026-01-01', '2026-12-31', 1, '2026-05-03 15:55:25'),
(10, 'CLEARANCE30', 'End-of-season clearance — 30% off select items', 'percentage', 30.00, 0.00, NULL, NULL, '2026-05-01', '2026-05-31', 1, '2026-05-03 15:55:25');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `inventory_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity_on_hand` int(11) NOT NULL DEFAULT 0,
  `reserved_quantity` int(11) NOT NULL DEFAULT 0,
  `available_stock` int(11) GENERATED ALWAYS AS (`quantity_on_hand` - `reserved_quantity`) STORED,
  `stock_status_id` int(11) NOT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`inventory_id`, `product_id`, `quantity_on_hand`, `reserved_quantity`, `stock_status_id`, `last_updated`) VALUES
(1, 1, 200, 45, 1, '2026-03-12 18:31:57'),
(2, 2, 150, 30, 1, '2026-03-12 18:31:57'),
(3, 3, 180, 25, 1, '2026-03-12 18:31:57'),
(4, 4, 100, 15, 1, '2026-03-12 18:31:57'),
(5, 5, 300, 60, 1, '2026-03-12 18:31:57'),
(6, 6, 250, 40, 1, '2026-03-12 18:31:57'),
(7, 7, 500, 80, 1, '2026-03-12 18:31:57'),
(8, 8, 400, 50, 1, '2026-03-12 18:31:57'),
(9, 9, 120, 20, 1, '2026-03-12 18:31:57'),
(10, 10, 250, 35, 1, '2026-03-12 18:31:57'),
(11, 11, 180, 25, 1, '2026-03-12 18:31:57'),
(12, 12, 90, 10, 2, '2026-03-12 18:31:57'),
(13, 13, 140, 20, 1, '2026-03-12 18:31:57'),
(14, 14, 110, 15, 1, '2026-03-12 18:31:57'),
(15, 15, 300, 45, 1, '2026-03-12 18:31:57');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_date` datetime DEFAULT current_timestamp(),
  `status_id` int(11) NOT NULL,
  `discount_id` int(11) DEFAULT NULL COMMENT 'Applied discount, if any',
  `delivery_address` text DEFAULT NULL,
  `delivery_time` datetime DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `order_date`, `status_id`, `discount_id`, `delivery_address`, `delivery_time`, `total_amount`) VALUES
(1, 5, '2026-02-15 09:30:00', 3, 1, '123 Main Street, Apt 4B, New York', '2026-02-17 14:00:00', 1029.98),
(2, 6, '2026-02-18 11:45:00', 3, NULL, '456 Oak Avenue, Suite 200, Los Angeles', '2026-02-20 10:00:00', 549.97),
(3, 7, '2026-02-22 14:20:00', 3, 3, '789 Pine Road, Chicago, IL 60614', '2026-02-24 15:30:00', 1699.97),
(4, 8, '2026-02-25 10:15:00', 3, NULL, '321 Elm Street, Houston, TX 77002', '2026-02-27 11:00:00', 169.98),
(5, 9, '2026-02-28 16:30:00', 2, 7, '654 Maple Drive, Phoenix, AZ 85001', '2026-03-02 13:00:00', 1699.98),
(6, 10, '2026-03-02 09:00:00', 2, NULL, '987 Cedar Lane, Philadelphia, PA 19103', '2026-03-04 16:00:00', 759.96),
(7, 11, '2026-03-05 13:45:00', 1, 9, '147 Birch Court, San Antonio, TX 78205', '2026-03-07 12:00:00', 279.96),
(8, 12, '2026-03-06 15:20:00', 1, NULL, '258 Spruce Street, San Diego, CA 92101', NULL, 189.97),
(9, 5, '2026-03-08 10:30:00', 3, 7, '123 Main Street, Apt 4B, New York', '2026-03-10 14:00:00', 649.98),
(10, 7, '2026-03-09 12:00:00', 1, NULL, '789 Pine Road, Chicago, IL 60614', NULL, 1829.96);

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price_at_purchase` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price_at_purchase`, `subtotal`) VALUES
(1, 1, 1, 1, 999.99, 999.99),
(2, 1, 7, 1, 29.99, 29.99),
(3, 2, 5, 1, 399.99, 399.99),
(4, 2, 8, 1, 59.99, 59.99),
(5, 2, 11, 1, 39.99, 39.99),
(6, 2, 15, 1, 49.99, 49.99),
(7, 3, 2, 1, 1199.99, 1199.99),
(8, 3, 5, 1, 399.99, 399.99),
(9, 3, 7, 1, 29.99, 29.99),
(10, 3, 10, 1, 89.99, 89.99),
(11, 4, 13, 2, 79.99, 159.98),
(12, 4, 12, 1, 79.99, 79.99),
(13, 5, 4, 1, 1499.99, 1499.99),
(14, 5, 1, 1, 999.99, 999.99),
(15, 6, 6, 1, 599.99, 599.99),
(16, 6, 5, 1, 399.99, 399.99),
(17, 6, 7, 2, 29.99, 59.98),
(18, 7, 9, 1, 149.99, 149.99),
(19, 7, 14, 1, 129.99, 129.99),
(20, 8, 10, 2, 89.99, 179.98),
(21, 8, 12, 1, 79.99, 79.99),
(22, 9, 6, 1, 599.99, 599.99),
(23, 9, 15, 1, 49.99, 49.99),
(24, 10, 3, 1, 1099.99, 1099.99),
(25, 10, 6, 1, 599.99, 599.99),
(26, 10, 14, 1, 129.99, 129.99);

-- --------------------------------------------------------

--
-- Table structure for table `order_status`
--

CREATE TABLE `order_status` (
  `status_id` int(11) NOT NULL,
  `status_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_status`
--

INSERT INTO `order_status` (`status_id`, `status_name`, `description`) VALUES
(1, 'Pending', 'Order placed but not yet confirmed or processed'),
(2, 'Processing', 'Order confirmed and being prepared for dispatch'),
(3, 'Completed', 'Order delivered and transaction finalised'),
(4, 'Cancelled', 'Order was cancelled before dispatch'),
(5, 'Refunded', 'Payment was refunded after cancellation or return'),
(6, 'On Hold', 'Order paused due to payment or stock issue'),
(7, 'Shipped', 'Order dispatched and in transit to customer'),
(8, 'Returned', 'Customer returned the item after delivery'),
(9, 'Failed', 'Order failed due to payment gateway error'),
(10, 'Awaiting Payment', 'Order created but payment not yet received');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `payment_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `payment_method_id` int(11) NOT NULL,
  `amount_paid` decimal(10,2) NOT NULL,
  `payment_status` varchar(50) NOT NULL,
  `payment_date` datetime DEFAULT current_timestamp(),
  `transaction_reference` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`payment_id`, `order_id`, `payment_method_id`, `amount_paid`, `payment_status`, `payment_date`, `transaction_reference`) VALUES
(1, 1, 1, 500.00, 'Completed', '2026-02-15 09:35:00', 'CASH-2026-001'),
(2, 1, 2, 529.98, 'Completed', '2026-02-15 09:35:00', 'CARD-TXN-450891'),
(3, 2, 2, 549.97, 'Completed', '2026-02-18 11:50:00', 'CARD-TXN-450892'),
(4, 3, 4, 1000.00, 'Completed', '2026-02-22 14:25:00', 'MPAY-GPAY-78901'),
(5, 3, 3, 699.97, 'Completed', '2026-02-22 14:26:00', 'DEBIT-TXN-340567'),
(6, 4, 1, 169.98, 'Completed', '2026-02-25 10:20:00', 'CASH-2026-002'),
(7, 5, 5, 1000.00, 'Completed', '2026-02-28 16:35:00', 'BANK-WIRE-123456'),
(8, 5, 2, 699.98, 'Pending', '2026-02-28 16:40:00', 'CARD-TXN-450893'),
(9, 6, 4, 759.96, 'Completed', '2026-03-02 09:05:00', 'MPAY-APPLEPAY-23456'),
(10, 7, 1, 279.96, 'Pending', '2026-03-05 13:50:00', NULL),
(11, 8, 3, 189.97, 'Completed', '2026-03-06 15:25:00', 'DEBIT-TXN-340568'),
(12, 9, 2, 649.98, 'Completed', '2026-03-08 10:35:00', 'CARD-TXN-450894'),
(13, 10, 1, 1000.00, 'Completed', '2026-03-09 12:05:00', 'CASH-2026-003'),
(14, 10, 2, 829.96, 'Pending', '2026-03-09 12:06:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payment_methods`
--

CREATE TABLE `payment_methods` (
  `method_id` int(11) NOT NULL,
  `method_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment_methods`
--

INSERT INTO `payment_methods` (`method_id`, `method_name`, `description`) VALUES
(1, 'Cash', 'Payment made in physical currency at the counter'),
(2, 'Credit Card', 'Payment via Visa, MasterCard, or AMEX credit card'),
(3, 'Debit Card', 'Payment directly deducted from customer bank account'),
(4, 'Mobile Payment', 'Payment via Google Pay, Apple Pay, or similar wallets'),
(5, 'Bank Transfer', 'Direct wire transfer from customer bank account'),
(6, 'Cheque', 'Payment via bank-issued cheque'),
(7, 'Gift Card', 'Store-issued gift card redeemed at checkout'),
(8, 'Cryptocurrency', 'Payment in Bitcoin, Ethereum, or other crypto'),
(9, 'Instalment Plan', 'Buy-now-pay-later split payment plan'),
(10, 'Store Credit', 'Credit issued by the store from returns or promotions');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `category_id` int(11) NOT NULL,
  `supplier_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `description`, `price`, `category_id`, `supplier_id`, `created_at`) VALUES
(1, 'iPhone 15 Pro', 'Apple smartphone with A17 Pro chip and titanium design', 999.99, 1, 1, '2026-01-01 10:00:00'),
(2, 'Samsung Galaxy S24 Ultra', 'Android flagship with S Pen and AI features', 1199.99, 1, 2, '2026-01-01 10:00:00'),
(3, 'MacBook Air M3', '13-inch laptop with Apple M3 chip, 8GB RAM', 1099.99, 1, 1, '2026-01-01 10:00:00'),
(4, 'Dell XPS 15', '15.6-inch laptop, Intel i7, 16GB RAM, 512GB SSD', 1499.99, 1, 2, '2026-01-01 10:00:00'),
(5, 'Sony WH-1000XM5', 'Industry-leading noise-cancelling wireless headphones', 399.99, 1, 2, '2026-01-01 10:00:00'),
(6, 'iPad Air 5th Gen', '10.9-inch tablet with M1 chip', 599.99, 1, 1, '2026-01-01 10:00:00'),
(7, 'Premium Cotton T-Shirt', 'Soft organic cotton, available in multiple colours', 29.99, 2, 3, '2026-01-02 10:00:00'),
(8, 'Classic Blue Jeans', 'Durable denim with a perfect fit', 59.99, 2, 3, '2026-01-02 10:00:00'),
(9, 'Winter Jacket', 'Water-resistant insulated jacket', 149.99, 2, 3, '2026-01-02 10:00:00'),
(10, 'Running Shoes Pro', 'Professional running shoes with cushioned sole', 89.99, 3, 4, '2026-01-03 10:00:00'),
(11, 'Yoga Mat Premium', 'Non-slip eco-friendly yoga mat with carry strap', 39.99, 3, 4, '2026-01-03 10:00:00'),
(12, 'Fitness Tracker Band', 'Smart band with heart rate monitor and step counter', 79.99, 3, 1, '2026-01-03 10:00:00'),
(13, 'Coffee Maker Deluxe', 'Programmable 12-cup coffee maker with timer', 79.99, 4, 5, '2026-01-04 10:00:00'),
(14, 'Blender Pro 3000', 'High-speed blender for smoothies and soups', 129.99, 4, 5, '2026-01-04 10:00:00'),
(15, 'Database Design Book', 'Complete guide to database management systems', 49.99, 5, 6, '2026-01-05 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(11) NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `description`) VALUES
(1, 'Admin', 'Full system access — manages users, products, and reports'),
(2, 'Cashier', 'Processes sales, manages orders at the point of sale'),
(3, 'Customer', 'Registered customer who can place and track orders'),
(4, 'Manager', 'Oversees store operations, approves discounts'),
(5, 'Supervisor', 'Monitors cashier activity and resolves transaction issues'),
(6, 'Accountant', 'Access to financial reports and payment records'),
(7, 'Inventory', 'Manages stock levels and supplier communications'),
(8, 'Support', 'Handles customer complaints and returns'),
(9, 'Analyst', 'Read-only access for generating business reports'),
(10, 'Auditor', 'Reviews system logs and ensures compliance');

-- --------------------------------------------------------

--
-- Table structure for table `stock_status`
--

CREATE TABLE `stock_status` (
  `stock_status_id` int(11) NOT NULL,
  `status` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `stock_status`
--

INSERT INTO `stock_status` (`stock_status_id`, `status`, `description`) VALUES
(1, 'In Stock', 'Item is available and ready to be sold'),
(2, 'Low Stock', 'Quantity on hand is below the reorder threshold'),
(3, 'Out of Stock', 'No units currently available; awaiting restock'),
(4, 'Pre-Order', 'Item not yet received; accepting advance orders'),
(5, 'Discontinued', 'Item will no longer be restocked or sold'),
(6, 'Backordered', 'Item is temporarily unavailable from supplier'),
(7, 'Reserved', 'All available units are reserved for pending orders'),
(8, 'Damaged', 'Current stock is damaged and cannot be sold'),
(9, 'Seasonal', 'Item is available only during specific seasons'),
(10, 'Coming Soon', 'New item expected soon; not yet available for sale');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL,
  `supplier_name` varchar(100) NOT NULL,
  `contact_person` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`supplier_id`, `supplier_name`, `contact_person`, `email`, `phone`, `address`) VALUES
(1, 'Tech Supplies Inc', 'John Doe', 'john@techsupplies.com', '555-0001', '123 Tech Street, Silicon Valley'),
(2, 'Electronics Hub', 'Jane Smith', 'jane@electrohub.com', '555-0002', '456 Electric Ave, New York'),
(3, 'Fashion World', 'Bob Johnson', 'bob@fashionworld.com', '555-0003', '789 Fashion Blvd, Paris'),
(4, 'Sports Gear Co', 'Mike Wilson', 'mike@sportsgear.com', '555-0004', '321 Athletic Way, Chicago'),
(5, 'Home Essentials', 'Sarah Brown', 'sarah@homeessentials.com', '555-0005', '654 Comfort Lane, Austin'),
(6, 'Book Haven', 'David Lee', 'david@bookhaven.com', '555-0006', '987 Literary Road, Boston'),
(7, 'Toy Kingdom', 'Alice Green', 'alice@toykingdom.com', '555-0007', '111 Play Street, Orlando'),
(8, 'Health Plus', 'Chris Adams', 'chris@healthplus.com', '555-0008', '222 Wellness Ave, Denver'),
(9, 'Fresh Grocers', 'Maria Lopez', 'maria@freshgrocers.com', '555-0009', '333 Market Road, Dallas'),
(10, 'Office Pro Supplies', 'James Carter', 'james@officepro.com', '555-0010', '444 Office Park, Seattle');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `role_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email`, `password`, `phone`, `role_id`, `created_at`) VALUES
(1, 'Admin User', 'admin@pos.com', '$2y$10$hashedpassword001', '555-1001', 1, '2026-01-01 08:00:00'),
(2, 'Cashier One', 'cashier1@pos.com', '$2y$10$hashedpassword002', '555-1002', 2, '2026-01-02 08:00:00'),
(3, 'Cashier Two', 'cashier2@pos.com', '$2y$10$hashedpassword003', '555-1003', 2, '2026-01-02 08:00:00'),
(4, 'Cashier Three', 'cashier3@pos.com', '$2y$10$hashedpassword004', '555-1004', 2, '2026-01-03 08:00:00'),
(5, 'John Customer', 'john@email.com', '$2y$10$hashedpassword005', '555-2001', 3, '2026-01-05 09:00:00'),
(6, 'Jane Doe', 'jane@email.com', '$2y$10$hashedpassword006', '555-2002', 3, '2026-01-06 09:00:00'),
(7, 'Michael Smith', 'michael@email.com', '$2y$10$hashedpassword007', '555-2003', 3, '2026-01-07 09:00:00'),
(8, 'Emily Johnson', 'emily@email.com', '$2y$10$hashedpassword008', '555-2004', 3, '2026-01-08 09:00:00'),
(9, 'Robert Brown', 'robert@email.com', '$2y$10$hashedpassword009', '555-2005', 3, '2026-01-09 09:00:00'),
(10, 'Lisa Wilson', 'lisa@email.com', '$2y$10$hashedpassword010', '555-2006', 3, '2026-01-10 09:00:00'),
(11, 'David Martinez', 'david@email.com', '$2y$10$hashedpassword011', '555-2007', 3, '2026-01-11 09:00:00'),
(12, 'Sarah Anderson', 'sarah@email.com', '$2y$10$hashedpassword012', '555-2008', 3, '2026-01-12 09:00:00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `discounts`
--
ALTER TABLE `discounts`
  ADD PRIMARY KEY (`discount_id`),
  ADD UNIQUE KEY `uq_discount_code` (`discount_code`),
  ADD KEY `fk_discounts_product` (`product_id`),
  ADD KEY `fk_discounts_category` (`category_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD KEY `fk_inventory_product` (`product_id`),
  ADD KEY `fk_inventory_status` (`stock_status_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `fk_orders_user` (`user_id`),
  ADD KEY `fk_orders_status` (`status_id`),
  ADD KEY `fk_orders_discount` (`discount_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `fk_orderitems_order` (`order_id`),
  ADD KEY `fk_orderitems_product` (`product_id`);

--
-- Indexes for table `order_status`
--
ALTER TABLE `order_status`
  ADD PRIMARY KEY (`status_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`payment_id`),
  ADD KEY `fk_payments_order` (`order_id`),
  ADD KEY `fk_payments_method` (`payment_method_id`);

--
-- Indexes for table `payment_methods`
--
ALTER TABLE `payment_methods`
  ADD PRIMARY KEY (`method_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `fk_products_category` (`category_id`),
  ADD KEY `fk_products_supplier` (`supplier_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`);

--
-- Indexes for table `stock_status`
--
ALTER TABLE `stock_status`
  ADD PRIMARY KEY (`stock_status_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`supplier_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `uq_users_email` (`email`),
  ADD KEY `fk_users_role` (`role_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `discounts`
--
ALTER TABLE `discounts`
  MODIFY `discount_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `inventory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `order_status`
--
ALTER TABLE `order_status`
  MODIFY `status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `payment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `payment_methods`
--
ALTER TABLE `payment_methods`
  MODIFY `method_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `stock_status`
--
ALTER TABLE `stock_status`
  MODIFY `stock_status_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `supplier_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `discounts`
--
ALTER TABLE `discounts`
  ADD CONSTRAINT `fk_discounts_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_discounts_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_inventory_status` FOREIGN KEY (`stock_status_id`) REFERENCES `stock_status` (`stock_status_id`) ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_discount` FOREIGN KEY (`discount_id`) REFERENCES `discounts` (`discount_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_status` FOREIGN KEY (`status_id`) REFERENCES `order_status` (`status_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_orderitems_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orderitems_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_method` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`method_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_payments_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_products_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`) ON UPDATE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
