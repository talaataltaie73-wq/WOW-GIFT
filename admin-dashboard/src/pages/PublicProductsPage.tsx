import { useState } from "react";
import { useProducts, useCategories, useStores } from "@/hooks/useApi";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Search } from "lucide-react";
import { formatCurrency } from "@/lib/utils";

export default function PublicProductsPage() {
  const { data: products } = useProducts();
  const { data: categories } = useCategories();
  const { data: stores } = useStores();
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [storeFilter, setStoreFilter] = useState("all");

  const categoriesMap = Object.fromEntries((categories || []).map((c) => [c.id, c]));
  const storesMap = Object.fromEntries((stores || []).map((s) => [s.id, s]));

  const filtered = (products || []).filter((product) => {
    const matchSearch =
      product.name_ar.includes(search) ||
      product.name_en.toLowerCase().includes(search.toLowerCase());
    const matchCategory = categoryFilter === "all" || product.category_id === categoryFilter;
    const matchStore = storeFilter === "all" || product.store_id === storeFilter;
    return matchSearch && matchCategory && matchStore;
  });

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 via-surface to-white">
      <div className="max-w-7xl mx-auto px-4 py-10 sm:px-6 lg:px-8">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between mb-10">
          <div>
            <p className="text-sm text-text-secondary mb-2">واجهة عرض المنتجات والهدايا</p>
            <h1 className="text-3xl font-bold text-text">تصفح الهدايا والبوكسات بسهولة</h1>
            <p className="mt-2 text-sm text-text-secondary max-w-2xl">
              اكتشف تشكيلة Wow Gift من المنتجات المتوفرة، البوكسات المميزة، والأسعار الواضحة — جميعها متاحة للعرض مباشرة دون تسجيل دخول.
              لوحة الإدارة غير معروضة للزوار العاديين، ويمكن الوصول إليها فقط بكتابة /login يدوياً في المتصفح.
            </p>
          </div>
        </div>

        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4 mb-8">
          <div className="flex items-center gap-3 p-4 rounded-3xl bg-white shadow-sm border border-border">
            <div className="p-3 rounded-2xl bg-primary/10 text-primary">
              <Search className="h-5 w-5" />
            </div>
            <div>
              <p className="text-sm text-text-secondary">عدد المنتجات</p>
              <p className="text-xl font-bold text-text">{filtered.length}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-4 rounded-3xl bg-white shadow-sm border border-border">
            <div className="p-3 rounded-2xl bg-accent/10 text-accent">
              <span className="text-xl font-bold">🎁</span>
            </div>
            <div>
              <p className="text-sm text-text-secondary">صناديق الهدايا</p>
              <p className="text-xl font-bold text-text">{filtered.filter((p) => p.category_name?.includes("بوكس") || p.name_ar.includes("بوكس")).length}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-4 rounded-3xl bg-white shadow-sm border border-border">
            <div className="p-3 rounded-2xl bg-secondary/10 text-secondary">
              <span className="text-xl font-bold">🏬</span>
            </div>
            <div>
              <p className="text-sm text-text-secondary">المتاجر الموثوقة</p>
              <p className="text-xl font-bold text-text">{stores?.length ?? 0}</p>
            </div>
          </div>
          <div className="flex items-center gap-3 p-4 rounded-3xl bg-white shadow-sm border border-border">
            <div className="p-3 rounded-2xl bg-info/10 text-info">
              <span className="text-xl font-bold">💰</span>
            </div>
            <div>
              <p className="text-sm text-text-secondary">متوسط السعر</p>
              <p className="text-xl font-bold text-text">
                {products && products.length > 0 ? formatCurrency(Math.round(products.reduce((acc, product) => acc + product.price, 0) / products.length)) : "0"}
              </p>
            </div>
          </div>
        </div>

        <div className="grid gap-4 lg:grid-cols-[1.6fr_0.9fr]">
          <div className="space-y-6">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
              <div className="relative w-full max-w-md">
                <Input
                  placeholder="ابحث عن منتج..."
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pr-10"
                />
                <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
              </div>

              <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
                <select
                  className="border border-border rounded-2xl px-4 py-3 text-sm bg-white"
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                >
                  <option value="all">كل التصنيفات</option>
                  {(categories || []).map((category) => (
                    <option key={category.id} value={category.id}>
                      {category.name_ar}
                    </option>
                  ))}
                </select>

                <select
                  className="border border-border rounded-2xl px-4 py-3 text-sm bg-white"
                  value={storeFilter}
                  onChange={(e) => setStoreFilter(e.target.value)}
                >
                  <option value="all">كل المتاجر</option>
                  {(stores || []).filter((store) => store.status === "active").map((store) => (
                    <option key={store.id} value={store.id}>
                      {store.name_ar}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
              {filtered.map((product) => (
                <div key={product.id} className="overflow-hidden rounded-[32px] bg-white p-6 shadow-sm border border-border">
                  <img src={product.images[0]} alt={product.name_ar} className="mb-4 h-56 w-full rounded-3xl object-cover" />
                  <div className="mb-3 text-sm text-text-secondary">{categoriesMap[product.category_id]?.name_ar || "بدون تصنيف"}</div>
                  <h2 className="text-lg font-bold text-text mb-2">{product.name_ar}</h2>
                  <p className="text-sm text-text-secondary mb-4">{product.store_name || storesMap[product.store_id]?.name_ar || "متجر غير معروف"}</p>
                  <div className="flex items-center justify-between gap-3">
                    <span className="text-xl font-bold text-text">{formatCurrency(product.price)}</span>
                    <Badge variant={product.stock > 0 ? (product.stock <= 5 ? "warning" : "success") : "danger"}>
                      {product.stock > 0 ? `${product.stock} متوفر` : "نفد"}
                    </Badge>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <aside className="space-y-6 rounded-[32px] bg-white p-6 shadow-sm border border-border">
            <div>
              <h3 className="text-lg font-bold text-text">عن Wow Gift</h3>
              <p className="mt-3 text-sm text-text-secondary leading-7">
                تصفح أفضل منتجات الهدايا من متاجر موثوقة بدون الحاجة لتسجيل دخول. لوحة الإدارة لا تظهر في الواجهة العامة ويجب الوصول إليها مباشرة عبر عنوان /login عند الطلب.
              </p>
            </div>

            <div className="space-y-3">
              <div className="rounded-3xl bg-primary/5 p-4">
                <p className="text-sm text-text-secondary">المتجر الأكثر مبيعاً</p>
                <p className="mt-2 text-base font-semibold text-text">{stores?.find((store) => store.status === "active")?.name_ar || "لا يوجد"}</p>
              </div>
              <div className="rounded-3xl bg-secondary/5 p-4">
                <p className="text-sm text-text-secondary">أفضل فئة</p>
                <p className="mt-2 text-base font-semibold text-text">{categories?.[0]?.name_ar || "لا يوجد"}</p>
              </div>
            </div>
          </aside>
        </div>
      </div>
    </div>
  );
}
