export interface User {
  id: string;
  email: string;
  name: string;
  role: "merchant" | "admin" | "customer";
  phone?: string;
  is_active?: boolean;
  created_at?: string;
}

export interface Store {
  id: string;
  merchant_id: string;
  merchant_name?: string;
  name_ar: string;
  name_en: string;
  description_ar: string;
  description_en: string;
  logo_url: string;
  cover_url: string;
  phone: string;
  email: string;
  status: "active" | "inactive" | "pending" | "suspended" | "rejected";
  rating?: number;
  product_count?: number;
  created_at: string;
  documents?: StoreDocument[];
  terms_accepted?: boolean;
  info_accurate?: boolean;
  privacy_accepted?: boolean;
}

export interface StoreDocument {
  name: string;
  url: string;
  status: "approved" | "pending" | "rejected";
}

export interface Product {
  id: string;
  store_id: string;
  store_name?: string;
  name_ar: string;
  name_en: string;
  description_ar: string;
  description_en: string;
  price: number;
  discount_price?: number;
  category_id: string;
  category_name?: string;
  stock: number;
  images: string[];
  status: "active" | "inactive" | "hidden";
  created_at: string;
}

export interface Category {
  id: string;
  name_ar: string;
  name_en: string;
  icon?: string;
  sort_order?: number;
  is_active?: boolean;
}

export interface Order {
  id: string;
  order_number: string;
  customer_name: string;
  customer_phone: string;
  store_id: string;
  store_name?: string;
  items: OrderItem[];
  total: number;
  status: OrderStatus;
  created_at: string;
  updated_at: string;
  delivery_address: string;
  notes?: string;
  greeting_card?: string;
  private_message?: string;
  is_anonymous?: boolean;
  delivery_date?: string;
  delivery_time_slot?: string;
}

export type OrderStatus =
  | "pending_approval"
  | "accepted"
  | "preparing"
  | "out_for_delivery"
  | "delivered"
  | "cancelled";

export interface OrderItem {
  id: string;
  product_id: string;
  product_name: string;
  quantity: number;
  price: number;
  total: number;
}

export interface Coupon {
  id: string;
  code: string;
  type: "percentage" | "fixed";
  value: number;
  min_order: number;
  usage_limit: number;
  used_count: number;
  expiry_date: string;
  is_active: boolean;
  created_at: string;
}

export interface Banner {
  id: string;
  title: string;
  image_url: string;
  link_target: string;
  start_date: string;
  end_date: string;
  is_active: boolean;
  created_at: string;
}

export interface Notification {
  id: string;
  title: string;
  message: string;
  type: "order" | "system" | "store" | "user";
  is_read: boolean;
  created_at: string;
}

export interface DashboardStats {
  total_users: number;
  active_stores: number;
  total_orders: number;
  platform_revenue: number;
  users_trend: number;
  stores_trend: number;
  orders_trend: number;
  revenue_trend: number;
  monthly_orders: { month: string; orders: number }[];
  order_status_distribution: { name: string; value: number; color: string }[];
  pending_approvals: Store[];
}

export interface ReportData {
  revenue_over_time: { date: string; revenue: number }[];
  top_products: { name: string; sales: number; image?: string }[];
  sales_by_occasion: { name: string; value: number; color: string }[];
  top_stores: { rank: number; name: string; orders: number; revenue: number }[];
  total_commission: number;
  commission_trend: number;
  avg_commission_per_order: number;
  total_revenue: number;
  coupon_usage: { code: string; usage_count: number; total_discount: number }[];
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: User;
}
