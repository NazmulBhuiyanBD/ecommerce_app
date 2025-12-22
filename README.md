# 🛒 Flutter E-Commerce Application

A complete **Flutter-based E-Commerce mobile application** supporting **Customers, Shop Owners, and Admins**.  
The system includes product management, cart & checkout, online payment integration (test mode), and role-based dashboards using **Firebase**.

## 📱 Screenshots

All application screenshots are available inside the **`/Screenshot`** folder.

Included screens:
- Admin Dashboard
- Manage Categories
- Manage Products
- Store List
- Orders Management
- Users List
- Login & Registration
- Product Listing
- Product Details
- Cart & Checkout
- Online Payment (bKash, Nagad, SSLCommerz)
- Order Details
- Purchase History
- Customer Profile
- Shop Owner Dashboard
- Shop Settings
- Add Product
- Shop Owner Products
- Shop Orders

---

## User Roles & Features

### Customer
- Browse products by category
- View product details
- Add products to cart
- Buy Now option
- Checkout with:
  - Cash on Delivery
  - Online Payment (Test Mode)
- View order history
- Track order status
- Manage profile

---

### Shop Owner
- Automatic shop creation if not exists
- Update shop settings (name, description, banner)
- Add and manage products
- View shop-specific orders
- Dashboard with quick action tiles

---

### Admin
- Admin dashboard overview
- Manage:
  - Products
  - Categories
  - Stores
  - Customers
  - Shop owners
  - Orders
- Enable / Disable users
- Monitor platform activity

---

## 💳 Payment Integration (Test Mode)

Online payment gateways are integrated **for testing purposes only**:

- **bKash**
- **Nagad**
- **SSLCommerz**

Production credentials can be added later.

---

## Tech 

- **Frontend:** Flutter (Material UI)
- **State Management:** Provider
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
- **Image Storage:** Cloudinary
- **Payments:**
  - flutter_bkash
  - nagad_payment_gateway
  - flutter_sslcommerz

---

## 📸 Screenshots

---

### 🔐 Authentication
| Login | Register |
|:-----:|:--------:|
| ![Login](ScreenShot/loginscreen.png) | ![Register](ScreenShot/registration.png) |

---

### 🏠 Onboarding
| Onboarding 1 | Onboarding 2 |
|:------------:|:------------:|
| ![Onboarding 1](ScreenShot/onBroadingScreen1.png) | ![Onboarding 2](ScreenShot/onBroadingScreen2.png) |

---

### 🛍 Customer Flow
|First Screen| All Products | Product Details |
|:------------:|:---------------:|:------------:|
| ![Main Screen](ScreenShot/screen1.png)| ![All Products](ScreenShot/all_product.png) | ![Product Details](ScreenShot/product_details.png) |

| Online Payment |SSLCommerce |Bkash | Order Details |
|:--------------:|:-------------:|:-------------:|
| ![Online Payment](ScreenShot/online_Payment.png) | ![Payment Method](ScreenShot/sslCommerce.png)|![Payment Method](ScreenShot/bkashCheckout.png)| ![Order Details](ScreenShot/order_details.png) |

| Purchase History | Customer Profile |
|:----------------:|:----------------:|
| ![Purchase History](ScreenShot/purchase_history.png) | ![Customer Profile](ScreenShot/customerProfile.png) |

---

### 🏪 Shop Owner
| Dashboard | Products | Settings |
|:---------:|:--------:|:--------:|
| ![Dashboard](ScreenShot/shop_owner_dashboard.png) | ![Products](ScreenShot/shop_owner_product.png) | ![Settings](ScreenShot/shop_setting.png) |

---

### 🛠 Admin Panel
| Dashboard | Categories |
|:---------:|:----------:|
| ![Dashboard](ScreenShot/adminDashboard.png) | ![Categories](ScreenShot/admin_manageCategory.png) |

| Orders | Products |
|:------:|:--------:|
| ![Orders](ScreenShot/admin_managerOrder.png) | ![Products](ScreenShot/admin_productList.png) |

| Stores | Users |
|:------:|:-----:|
| ![Stores](ScreenShot/admin_storeList.png) | ![Users](ScreenShot/all_userList.png) |

