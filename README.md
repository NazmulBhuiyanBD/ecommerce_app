# 🛒 Flutter E-Commerce Application

A complete **Flutter-based E-Commerce mobile application** supporting **Customers, Shop Owners, and Admins**.  
The system includes **product management, cart & checkout, online payment integration (test mode)**, and **role-based dashboards** powered by **Firebase**.

## ⚙️ Environment Setup (Required)

To run this project, you must create the following file:
root/
└── lib/
└── utils/
└── env.dart

### 📄 `env.dart` Content

class Env {
  static const String cloudName = "Your Cloudinary Cloud Name";
  static const String uploadPreset = "Your Cloudinary Upload Preset";

  static const String sslstore_id = "Your SSLCommerz Store ID";
  static const String sslstore_passwd = "Your SSLCommerz Password";
}


## 📱 Application Screenshots

All screenshots are available inside the **`/ScreenShot`** folder.

**Included screens**
- Authentication (Login & Registration)
- Onboarding
- Product Listing & Details
- Cart & Checkout
- Online Payments (bKash, Nagad, SSLCommerz – Test Mode)
- Order Details & Purchase History
- Customer Profile
- Shop Owner Dashboard & Product Management
- Admin Dashboard & System Management



## 👥 User Roles & Features

### 👤 Customer
- Browse products by category
- View product details
- Add products to cart
- Buy Now option
- Checkout with:
  - Cash on Delivery
  - Online Payment (Test Mode)
- View purchase history
- Track order status
- Manage profile



### 🏪 Shop Owner
- Automatic shop creation (if not exists)
- Update shop settings (name, description, banner)
- Add, update, and manage products
- View shop-specific orders
- Dashboard with quick-access tiles



### 🛠 Admin
- Dashboard overview
- Manage:
  - Products
  - Categories
  - Stores
  - Customers
  - Shop owners
  - Orders
- Enable / disable users
- Monitor overall platform activity



## 💳 Payment Integration (Test Mode)

Integrated online payment gateways **for testing purposes only**:

- **bKash**
- **Nagad**
- **SSLCommerz**

> Production credentials can be configured later.



## 🧰 Tech Stack

- **Frontend:** Flutter (Material UI)
- **State Management:** Provider
- **Backend:** Firebase  
  - Firebase Authentication  
  - Cloud Firestore
- **Image Storage:** Cloudinary
- **Payments:**
  - `flutter_bkash`
  - `nagad_payment_gateway`
  - `flutter_sslcommerz`



## 📸 Screenshots

### 🔐 Authentication
| Login | Register |
|:-----:|:--------:|
| ![Login](ScreenShot/loginscreen.png) | ![Register](ScreenShot/registration.png) |



### 🏠 Onboarding
| Onboarding 1 | Onboarding 2 |
|:------------:|:------------:|
| ![Onboarding 1](ScreenShot/onBroadingScreen1.png) | ![Onboarding 2](ScreenShot/onBroadingScreen2.png) |



### 🛍 Customer Flow
| Home | All Products | Product Details |
|:----:|:------------:|:---------------:|
| ![Home](ScreenShot/screen1.png) | ![All Products](ScreenShot/all_product.png) | ![Product Details](ScreenShot/product_details.png) |

| Online Payment | SSLCommerz | bKash | Order Details |
|:--------------:|:----------:|:-----:|:-------------:|
| ![Payment](ScreenShot/online_Payment.png) | ![SSL](ScreenShot/sslCommerce.png) | ![bKash](ScreenShot/bkashCheckout.png) | ![Order](ScreenShot/order_details.png) |

| Purchase History | Customer Profile |
|:----------------:|:----------------:|
| ![History](ScreenShot/purchase_history.png) | ![Profile](ScreenShot/customerProfile.png) |



### 🏪 Shop Owner
| Dashboard | Products | Settings |
|:---------:|:--------:|:--------:|
| ![Dashboard](ScreenShot/shop_owner_dashboard.png) | ![Products](ScreenShot/shop_owner_product.png) | ![Settings](ScreenShot/shop_setting.png) |



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



## 🚀 Future Improvements
- Production payment credentials
- Push notifications
- Order tracking with real-time updates
- Analytics dashboard
- Web admin panel

---

## 📄 License
This project is for **educational and demonstration purposes**.
