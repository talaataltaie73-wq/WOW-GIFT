import type {
  User,
  Store,
  Product,
  Order,
  Category,
  Coupon,
  Banner,
  Notification,
  DashboardStats,
  ReportData,
  StoreDocument,
} from "@/types";

export const mockAdminUser: User = {
  id: "a1",
  email: "admin@wowgift.iq",
  name: "مدير المنصة",
  role: "admin",
  phone: "+9647701234567",
};

export const mockUsers: User[] = [
  { id: "u1", email: "ahmed@gmail.com", name: "أحمد محمد", role: "customer", phone: "+9647701111111", is_active: true, created_at: "2024-01-15T10:00:00Z" },
  { id: "u2", email: "sara@gmail.com", name: "سارة خالد", role: "customer", phone: "+9647702222222", is_active: true, created_at: "2024-02-20T10:00:00Z" },
  { id: "u3", email: "mohammad@alward.com", name: "محمد علي", role: "merchant", phone: "+9647703333333", is_active: true, created_at: "2024-03-10T10:00:00Z" },
  { id: "u4", email: "noor@lamasat.com", name: "نور حسين", role: "merchant", phone: "+9647704444444", is_active: true, created_at: "2024-03-15T10:00:00Z" },
  { id: "u5", email: "zainab@gmail.com", name: "زينب كاظم", role: "customer", phone: "+9647705555555", is_active: false, created_at: "2024-04-01T10:00:00Z" },
  { id: "u6", email: "ali@gmail.com", name: "علي حسن", role: "customer", phone: "+9647706666666", is_active: true, created_at: "2024-04-10T10:00:00Z" },
  { id: "u7", email: "fatima@gifts.com", name: "فاطمة العلي", role: "merchant", phone: "+9647707777777", is_active: true, created_at: "2024-05-01T10:00:00Z" },
  { id: "u8", email: "hassan@gmail.com", name: "حسن عبدالله", role: "customer", phone: "+9647708888888", is_active: true, created_at: "2024-05-15T10:00:00Z" },
  { id: "a1", email: "admin@wowgift.iq", name: "مدير المنصة", role: "admin", phone: "+9647701234567", is_active: true, created_at: "2024-01-01T10:00:00Z" },
];

const storeDocuments: StoreDocument[] = [
  { name: "السجل التجاري.pdf", url: "#", status: "approved" },
  { name: "الهوية الوطنية.pdf", url: "#", status: "approved" },
  { name: "رخصة مزاولة النشاط.pdf", url: "#", status: "approved" },
  { name: "شهادة الضريبة.pdf", url: "#", status: "approved" },
];

export const mockStores: Store[] = [
  {
    id: "s1", merchant_id: "u3", merchant_name: "محمد علي", name_ar: "هدايا الورد", name_en: "Al Ward Gifts",
    description_ar: "متجر متخصص في هدايا الورود والباقات الفاخرة", description_en: "Specialized in flower gifts",
    logo_url: "https://placehold.co/80x80/0F766E/FFFFFF?text=🎁", cover_url: "", phone: "+9647703333333",
    email: "mohammad@alward.com", status: "pending", rating: 4.5, product_count: 45, created_at: "2024-05-22T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
  {
    id: "s2", merchant_id: "u4", merchant_name: "نور حسين", name_ar: "لمسات راقية", name_en: "Lamasat Raqia",
    description_ar: "هدايا فاخرة وتغليف راقي", description_en: "Luxury gifts and wrapping",
    logo_url: "https://placehold.co/80x80/D4AF37/111827?text=LR", cover_url: "", phone: "+9647704444444",
    email: "noor@lamasat.com", status: "pending", rating: 4.8, product_count: 32, created_at: "2024-05-21T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
  {
    id: "s3", merchant_id: "u7", merchant_name: "سارة خالد", name_ar: "تفاصيل فاخرة", name_en: "Tafaseel Fakhira",
    description_ar: "تفاصيل فاخرة لكل مناسبة", description_en: "Luxury details for every occasion",
    logo_url: "https://placehold.co/80x80/8B4513/FFFFFF?text=TF", cover_url: "", phone: "+9647707777777",
    email: "sara@tafaseel.com", status: "active", rating: 4.2, product_count: 28, created_at: "2024-05-21T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
  {
    id: "s4", merchant_id: "u3", merchant_name: "أحمد حسن", name_ar: "عالم الهدايا", name_en: "Gift World",
    description_ar: "عالم واسع من الهدايا المميزة", description_en: "A wide world of special gifts",
    logo_url: "https://placehold.co/80x80/1a1a2e/D4AF37?text=GW", cover_url: "", phone: "+9647703333333",
    email: "ahmed@alamalhdaia.com", status: "pending", rating: 4.0, product_count: 56, created_at: "2024-05-20T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
  {
    id: "s5", merchant_id: "u4", merchant_name: "زينب كاظم", name_ar: "بيت الذوق", name_en: "Bait Al Thawq",
    description_ar: "بيت الذوق الرفيع للهدايا", description_en: "House of fine taste for gifts",
    logo_url: "https://placehold.co/80x80/DC143C/FFFFFF?text=BT", cover_url: "", phone: "+9647704444444",
    email: "zainab@baitalthawq.com", status: "rejected", rating: 3.8, product_count: 12, created_at: "2024-05-19T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
  {
    id: "s6", merchant_id: "u7", merchant_name: "فاطمة العلي", name_ar: "هدايا العاصمة", name_en: "Capital Gifts",
    description_ar: "أفضل الهدايا في العاصمة بغداد", description_en: "Best gifts in Baghdad",
    logo_url: "https://placehold.co/80x80/0F766E/D4AF37?text=HQ", cover_url: "", phone: "+9647707777777",
    email: "fatima@capitalg.com", status: "active", rating: 4.7, product_count: 67, created_at: "2024-04-15T10:00:00Z",
    documents: storeDocuments, terms_accepted: true, info_accurate: true, privacy_accepted: true,
  },
];

export const mockCategories: Category[] = [
  { id: "c1", name_ar: "هدايا فاخرة", name_en: "Luxury Gifts", icon: "🎁", sort_order: 1, is_active: true },
  { id: "c2", name_ar: "شوكولاتة", name_en: "Chocolate", icon: "🍫", sort_order: 2, is_active: true },
  { id: "c3", name_ar: "عطور", name_en: "Perfumes", icon: "🧴", sort_order: 3, is_active: true },
  { id: "c4", name_ar: "ورود", name_en: "Flowers", icon: "🌹", sort_order: 4, is_active: true },
  { id: "c5", name_ar: "إكسسوارات", name_en: "Accessories", icon: "⌚", sort_order: 5, is_active: true },
  { id: "c6", name_ar: "تغليف هدايا", name_en: "Gift Wrapping", icon: "🎀", sort_order: 6, is_active: true },
  { id: "c7", name_ar: "ألعاب", name_en: "Toys", icon: "🧸", sort_order: 7, is_active: false },
];

export const mockProducts: Product[] = [
  { id: "p1", store_id: "s3", store_name: "تفاصيل فاخرة", name_ar: "باقة ورد فاخرة", name_en: "Luxury Rose Bouquet", description_ar: "باقة ورد طبيعي فاخرة", description_en: "Premium natural rose bouquet", price: 85000, category_id: "c4", category_name: "ورود", stock: 25, images: ["https://placehold.co/400x400/DC143C/FFFFFF?text=Roses"], status: "active", created_at: "2024-06-01T10:00:00Z" },
  { id: "p2", store_id: "s6", store_name: "هدايا العاصمة", name_ar: "عطر كريد أفينتوس", name_en: "Creed Aventus", description_ar: "عطر كريد أفينتوس الفاخر", description_en: "Luxury Creed Aventus perfume", price: 450000, category_id: "c3", category_name: "عطور", stock: 10, images: ["https://placehold.co/400x400/1a1a2e/D4AF37?text=Perfume"], status: "active", created_at: "2024-06-05T10:00:00Z" },
  { id: "p3", store_id: "s3", store_name: "تفاصيل فاخرة", name_ar: "طقم مونت بلانك فاخر", name_en: "Mont Blanc Set", description_ar: "طقم مونت بلانك أقلام فاخرة", description_en: "Premium Mont Blanc pen set", price: 320000, category_id: "c1", category_name: "هدايا فاخرة", stock: 5, images: ["https://placehold.co/400x400/2C3E50/FFFFFF?text=MontBlanc"], status: "active", created_at: "2024-06-10T10:00:00Z" },
  { id: "p4", store_id: "s6", store_name: "هدايا العاصمة", name_ar: "هدايا العيد الفاخرة", name_en: "Luxury Eid Gifts", description_ar: "مجموعة هدايا العيد الفاخرة", description_en: "Premium Eid gift collection", price: 150000, category_id: "c1", category_name: "هدايا فاخرة", stock: 30, images: ["https://placehold.co/400x400/D4AF37/111827?text=Eid"], status: "active", created_at: "2024-06-15T10:00:00Z" },
  { id: "p5", store_id: "s3", store_name: "تفاصيل فاخرة", name_ar: "ساعة رولكس رجالية", name_en: "Rolex Men Watch", description_ar: "ساعة رولكس رجالية أصلية", description_en: "Original Rolex men's watch", price: 2500000, category_id: "c5", category_name: "إكسسوارات", stock: 3, images: ["https://placehold.co/400x400/0F766E/D4AF37?text=Rolex"], status: "active", created_at: "2024-06-20T10:00:00Z" },
  { id: "p6", store_id: "s6", store_name: "هدايا العاصمة", name_ar: "شوكولاتة بلجيكية فاخرة", name_en: "Belgian Chocolate", description_ar: "شوكولاتة بلجيكية أصلية", description_en: "Authentic Belgian chocolate", price: 65000, category_id: "c2", category_name: "شوكولاتة", stock: 50, images: ["https://placehold.co/400x400/8B4513/FFFFFF?text=Choco"], status: "active", created_at: "2024-06-25T10:00:00Z" },
  { id: "p7", store_id: "s3", store_name: "تفاصيل فاخرة", name_ar: "طقم تغليف ذهبي", name_en: "Gold Wrapping Set", description_ar: "طقم تغليف هدايا ذهبي فاخر", description_en: "Premium gold gift wrapping set", price: 35000, category_id: "c6", category_name: "تغليف هدايا", stock: 0, images: ["https://placehold.co/400x400/D4AF37/FFFFFF?text=Wrap"], status: "inactive", created_at: "2024-07-01T10:00:00Z" },
];

export const mockOrders: Order[] = [
  {
    id: "o1", order_number: "WG-2024-001", customer_name: "سارة أحمد", customer_phone: "+9647751234567",
    store_id: "s3", store_name: "تفاصيل فاخرة",
    items: [
      { id: "oi1", product_id: "p1", product_name: "باقة ورد فاخرة", quantity: 2, price: 85000, total: 170000 },
      { id: "oi2", product_id: "p6", product_name: "شوكولاتة بلجيكية فاخرة", quantity: 1, price: 65000, total: 65000 },
    ],
    total: 235000, status: "pending_approval", created_at: "2024-07-20T14:30:00Z", updated_at: "2024-07-20T14:30:00Z",
    delivery_address: "بغداد، المنصور، شارع 14 رمضان", greeting_card: "كل عام وأنتِ بخير يا أمي الغالية 💐", private_message: "أرجو التوصيل قبل الساعة 6 مساءً", is_anonymous: false,
  },
  {
    id: "o2", order_number: "WG-2024-002", customer_name: "محمد العلي", customer_phone: "+9647759876543",
    store_id: "s6", store_name: "هدايا العاصمة",
    items: [{ id: "oi3", product_id: "p2", product_name: "عطر كريد أفينتوس", quantity: 1, price: 450000, total: 450000 }],
    total: 450000, status: "accepted", created_at: "2024-07-19T10:00:00Z", updated_at: "2024-07-19T11:00:00Z",
    delivery_address: "بغداد، زيونة، شارع فلسطين", is_anonymous: true,
  },
  {
    id: "o3", order_number: "WG-2024-003", customer_name: "نورة الخالد", customer_phone: "+9647741112233",
    store_id: "s3", store_name: "تفاصيل فاخرة",
    items: [{ id: "oi4", product_id: "p3", product_name: "طقم مونت بلانك فاخر", quantity: 1, price: 320000, total: 320000 }],
    total: 320000, status: "preparing", created_at: "2024-07-18T09:00:00Z", updated_at: "2024-07-18T12:00:00Z",
    delivery_address: "البصرة، العشار", greeting_card: "مبروك التخرج! 🎓",
  },
  {
    id: "o4", order_number: "WG-2024-004", customer_name: "فهد السعيد", customer_phone: "+9647733445566",
    store_id: "s6", store_name: "هدايا العاصمة",
    items: [{ id: "oi5", product_id: "p5", product_name: "ساعة رولكس رجالية", quantity: 1, price: 2500000, total: 2500000 }],
    total: 2500000, status: "out_for_delivery", created_at: "2024-07-17T08:00:00Z", updated_at: "2024-07-17T16:00:00Z",
    delivery_address: "أربيل، شارع 40 متري",
  },
  {
    id: "o5", order_number: "WG-2024-005", customer_name: "ريم الحربي", customer_phone: "+9647722334455",
    store_id: "s3", store_name: "تفاصيل فاخرة",
    items: [
      { id: "oi6", product_id: "p4", product_name: "هدايا العيد الفاخرة", quantity: 3, price: 150000, total: 450000 },
      { id: "oi7", product_id: "p1", product_name: "باقة ورد فاخرة", quantity: 2, price: 85000, total: 170000 },
    ],
    total: 620000, status: "delivered", created_at: "2024-07-15T11:00:00Z", updated_at: "2024-07-16T14:00:00Z",
    delivery_address: "النجف، شارع الرسول",
  },
  {
    id: "o6", order_number: "WG-2024-006", customer_name: "عبدالله الشمري", customer_phone: "+9647711223344",
    store_id: "s6", store_name: "هدايا العاصمة",
    items: [{ id: "oi8", product_id: "p6", product_name: "شوكولاتة بلجيكية فاخرة", quantity: 2, price: 65000, total: 130000 }],
    total: 130000, status: "cancelled", created_at: "2024-07-14T15:00:00Z", updated_at: "2024-07-14T16:00:00Z",
    delivery_address: "كربلاء، حي العباس",
  },
  {
    id: "o7", order_number: "WG-2024-007", customer_name: "لمى العتيبي", customer_phone: "+9647744556677",
    store_id: "s3", store_name: "تفاصيل فاخرة",
    items: [{ id: "oi9", product_id: "p2", product_name: "عطر كريد أفينتوس", quantity: 1, price: 450000, total: 450000 }],
    total: 450000, status: "delivered", created_at: "2024-07-12T10:00:00Z", updated_at: "2024-07-13T18:00:00Z",
    delivery_address: "بغداد، الكرادة",
  },
];

export const mockCoupons: Coupon[] = [
  { id: "cp1", code: "EID25", type: "percentage", value: 25, min_order: 100000, usage_limit: 500, used_count: 1245, expiry_date: "2024-12-31T23:59:59Z", is_active: true, created_at: "2024-01-01T10:00:00Z" },
  { id: "cp2", code: "WOW15", type: "percentage", value: 15, min_order: 50000, usage_limit: 1000, used_count: 980, expiry_date: "2024-09-30T23:59:59Z", is_active: true, created_at: "2024-03-01T10:00:00Z" },
  { id: "cp3", code: "HBD20", type: "percentage", value: 20, min_order: 75000, usage_limit: 300, used_count: 760, expiry_date: "2024-08-31T23:59:59Z", is_active: true, created_at: "2024-04-01T10:00:00Z" },
  { id: "cp4", code: "WELCOME10", type: "fixed", value: 10000, min_order: 50000, usage_limit: 2000, used_count: 540, expiry_date: "2024-12-31T23:59:59Z", is_active: true, created_at: "2024-01-15T10:00:00Z" },
  { id: "cp5", code: "GRAD25", type: "percentage", value: 25, min_order: 100000, usage_limit: 200, used_count: 320, expiry_date: "2024-07-31T23:59:59Z", is_active: false, created_at: "2024-05-01T10:00:00Z" },
];

export const mockBanners: Banner[] = [
  { id: "b1", title: "عروض عيد الأضحى", image_url: "https://placehold.co/1200x400/0F766E/FFFFFF?text=Eid+Offers", link_target: "/products?occasion=eid", start_date: "2024-06-01T00:00:00Z", end_date: "2024-06-30T23:59:59Z", is_active: true, created_at: "2024-05-25T10:00:00Z" },
  { id: "b2", title: "هدايا التخرج", image_url: "https://placehold.co/1200x400/D4AF37/111827?text=Graduation", link_target: "/products?occasion=graduation", start_date: "2024-05-01T00:00:00Z", end_date: "2024-07-31T23:59:59Z", is_active: true, created_at: "2024-04-20T10:00:00Z" },
  { id: "b3", title: "خصم 20% على الورود", image_url: "https://placehold.co/1200x400/DC143C/FFFFFF?text=Flowers+20%25", link_target: "/products?category=flowers", start_date: "2024-07-01T00:00:00Z", end_date: "2024-07-15T23:59:59Z", is_active: false, created_at: "2024-06-28T10:00:00Z" },
];

export const mockNotifications: Notification[] = [
  { id: "n1", title: "طلب اعتماد متجر جديد", message: "متجر 'هدايا الورد' يطلب الاعتماد - يرجى المراجعة", type: "store", is_read: false, created_at: "2024-07-20T14:30:00Z" },
  { id: "n2", title: "طلب جديد", message: "طلب جديد رقم WG-2024-001 بقيمة 235,000 د.ع", type: "order", is_read: false, created_at: "2024-07-20T14:00:00Z" },
  { id: "n3", title: "مستخدم جديد", message: "تسجيل مستخدم جديد: حسن عبدالله", type: "user", is_read: false, created_at: "2024-07-19T08:00:00Z" },
  { id: "n4", title: "تحديث النظام", message: "تم تحديث النظام بنجاح إلى الإصدار 2.1.0", type: "system", is_read: true, created_at: "2024-07-18T12:00:00Z" },
  { id: "n5", title: "طلب تم تسليمه", message: "تم تسليم الطلب رقم WG-2024-005 بنجاح", type: "order", is_read: true, created_at: "2024-07-16T14:00:00Z" },
  { id: "n6", title: "متجر معلق", message: "تم تعليق متجر 'بيت الذوق' بسبب مخالفة", type: "store", is_read: true, created_at: "2024-07-15T10:00:00Z" },
];

export const mockDashboardStats: DashboardStats = {
  total_users: 24685,
  active_stores: 1248,
  total_orders: 8532,
  platform_revenue: 323450000,
  users_trend: 12.4,
  stores_trend: 8.7,
  orders_trend: 15.3,
  revenue_trend: 18.6,
  monthly_orders: [
    { month: "مايو", orders: 420 },
    { month: "يونيو", orders: 680 },
    { month: "يوليو", orders: 850 },
    { month: "أغسطس", orders: 920 },
    { month: "سبتمبر", orders: 1100 },
    { month: "أكتوبر", orders: 1250 },
    { month: "نوفمبر", orders: 1400 },
    { month: "ديسمبر", orders: 1580 },
    { month: "يناير", orders: 1350 },
    { month: "فبراير", orders: 1200 },
    { month: "مارس", orders: 1450 },
    { month: "أبريل", orders: 1850 },
  ],
  order_status_distribution: [
    { name: "مكتملة", value: 5120, color: "#0F766E" },
    { name: "قيد المعالجة", value: 2012, color: "#D4AF37" },
    { name: "ملغاة", value: 896, color: "#9CA3AF" },
    { name: "مسترجعة", value: 504, color: "#14B8A6" },
  ],
  pending_approvals: [],
};

export const mockReportData: ReportData = {
  revenue_over_time: [
    { date: "مايو 1", revenue: 8500000 },
    { date: "مايو 6", revenue: 12000000 },
    { date: "مايو 11", revenue: 15500000 },
    { date: "مايو 16", revenue: 42000000 },
    { date: "مايو 21", revenue: 38000000 },
    { date: "مايو 26", revenue: 28000000 },
    { date: "مايو 31", revenue: 18000000 },
  ],
  top_products: [
    { name: "باقة ورد فاخرة", sales: 2450, image: "https://placehold.co/40x40/DC143C/FFFFFF?text=🌹" },
    { name: "عطر كريد أفينتوس", sales: 1890, image: "https://placehold.co/40x40/1a1a2e/D4AF37?text=🧴" },
    { name: "طقم مونت بلانك فاخر", sales: 1320, image: "https://placehold.co/40x40/2C3E50/FFFFFF?text=✒️" },
    { name: "هدايا العيد الفاخرة", sales: 980, image: "https://placehold.co/40x40/D4AF37/111827?text=🎁" },
    { name: "ساعة رولكس رجالية", sales: 760, image: "https://placehold.co/40x40/0F766E/D4AF37?text=⌚" },
  ],
  sales_by_occasion: [
    { name: "عيد ميلاد", value: 35, color: "#0F766E" },
    { name: "عيد", value: 25, color: "#D4AF37" },
    { name: "زفاف", value: 18, color: "#3B82F6" },
    { name: "لها", value: 12, color: "#F59E0B" },
    { name: "له", value: 6, color: "#10B981" },
    { name: "تخرج", value: 4, color: "#9CA3AF" },
  ],
  top_stores: [
    { rank: 1, name: "بغداد - المنصور", orders: 1245, revenue: 42850000 },
    { rank: 2, name: "بغداد - زيونة", orders: 1032, revenue: 33210000 },
    { rank: 3, name: "البصرة - رسائل", orders: 765, revenue: 24560000 },
    { rank: 4, name: "أربيل - 40 متر", orders: 612, revenue: 19430000 },
    { rank: 5, name: "النجف - شارع الرسول", orders: 498, revenue: 14800000 },
  ],
  total_commission: 12485000,
  commission_trend: 16.3,
  avg_commission_per_order: 3450,
  total_revenue: 124850000,
  coupon_usage: [
    { code: "EID25", usage_count: 1245, total_discount: 8450000 },
    { code: "WOW15", usage_count: 980, total_discount: 5230000 },
    { code: "HBD20", usage_count: 760, total_discount: 3800000 },
    { code: "WELCOME10", usage_count: 540, total_discount: 2105000 },
    { code: "GRAD25", usage_count: 320, total_discount: 1260000 },
  ],
};
