import { useMemo, useState } from "react";
import { useProducts, useCategories, useStores, useUpdateProduct } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Search, Eye, EyeOff, Edit3 } from "lucide-react";
import { formatCurrency } from "@/lib/utils";
import type { Product } from "@/types";

export default function ProductsPage() {
  const { data: products } = useProducts();
  const { data: categories } = useCategories();
  const { data: stores } = useStores();
  const updateProduct = useUpdateProduct();
  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("all");
  const [storeFilter, setStoreFilter] = useState("all");
  const [editingProduct, setEditingProduct] = useState<Product | null>(null);
  const [formValues, setFormValues] = useState<{ name_ar: string; name_en: string; price: number; status: Product["status"] }>({ name_ar: "", name_en: "", price: 0, status: "active" });

  const filtered = (products || []).filter((p) => {
    const matchSearch = p.name_ar.includes(search) || p.name_en.toLowerCase().includes(search.toLowerCase());
    const matchCategory = categoryFilter === "all" || p.category_id === categoryFilter;
    const matchStore = storeFilter === "all" || p.store_id === storeFilter;
    return matchSearch && matchCategory && matchStore;
  });

  const currentStores = useMemo(
    () => Object.fromEntries((stores || []).map((store) => [store.id, store.name_ar])),
    [stores]
  );

  const openEditDialog = (product: Product) => {
    setEditingProduct(product);
    setFormValues({ name_ar: product.name_ar, name_en: product.name_en || "", price: product.price, status: product.status });
  };

  const handleSave = async () => {
    if (!editingProduct) return;
    await updateProduct.mutateAsync({ id: editingProduct.id, data: { name_ar: formValues.name_ar, name_en: formValues.name_en, price: formValues.price, status: formValues.status } });
    setEditingProduct(null);
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-text">المنتجات</h1>

      <Card className="p-6">
        <div className="flex flex-wrap items-center gap-4 mb-6">
          <div className="relative flex-1 min-w-[250px]">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
            <Input placeholder="بحث بالاسم..." value={search} onChange={(e) => setSearch(e.target.value)} className="pr-10" />
          </div>
          <select
            className="border border-border rounded-xl px-4 py-2 text-sm bg-white"
            value={categoryFilter}
            onChange={(e) => setCategoryFilter(e.target.value)}
          >
            <option value="all">كل التصنيفات</option>
            {(categories || []).map((c) => (
              <option key={c.id} value={c.id}>{c.name_ar}</option>
            ))}
          </select>
          <select
            className="border border-border rounded-xl px-4 py-2 text-sm bg-white"
            value={storeFilter}
            onChange={(e) => setStoreFilter(e.target.value)}
          >
            <option value="all">كل المتاجر</option>
            {(stores || []).filter((s) => s.status === "active").map((s) => (
              <option key={s.id} value={s.id}>{s.name_ar}</option>
            ))}
          </select>
        </div>

        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الصورة</TableHead>
              <TableHead>اسم المنتج</TableHead>
              <TableHead>المتجر</TableHead>
              <TableHead>التصنيف</TableHead>
              <TableHead>السعر</TableHead>
              <TableHead>المخزون</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((product) => (
              <TableRow key={product.id}>
                <TableCell>
                  <img src={product.images[0]} alt={product.name_ar} className="w-10 h-10 rounded-lg object-cover" />
                </TableCell>
                <TableCell className="font-medium">{product.name_ar}</TableCell>
                <TableCell>{product.store_name || "-"}</TableCell>
                <TableCell><Badge variant="secondary">{product.category_name || "-"}</Badge></TableCell>
                <TableCell>{formatCurrency(product.price)}</TableCell>
                <TableCell>
                  <Badge variant={product.stock > 0 ? (product.stock <= 5 ? "warning" : "success") : "danger"}>
                    {product.stock > 0 ? product.stock : "نفد"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={product.status === "active" ? "success" : "secondary"}>
                    {product.status === "active" ? "نشط" : "مخفي"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button size="sm" variant="ghost" title="تعديل المنتج" onClick={() => openEditDialog(product)}>
                      <Edit3 className="h-4 w-4" />
                    </Button>
                    <Button size="sm" variant="ghost" title={product.status === "active" ? "إخفاء" : "إظهار"}>
                      {product.status === "active" ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={!!editingProduct} onClose={() => setEditingProduct(null)}>
        <DialogHeader>
          <DialogTitle>تعديل المنتج</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div>
            <label className="text-sm font-medium text-text">اسم المنتج (عربي)</label>
            <Input
              value={formValues.name_ar}
              onChange={(e) => setFormValues({ ...formValues, name_ar: e.target.value })}
              className="mt-2"
            />
          </div>
          <div>
            <label className="text-sm font-medium text-text">Product Name (English)</label>
            <Input
              value={formValues.name_en}
              onChange={(e) => setFormValues({ ...formValues, name_en: e.target.value })}
              className="mt-2"
            />
          </div>
          <div>
            <label className="text-sm font-medium text-text">السعر</label>
            <Input
              type="number"
              value={formValues.price}
              onChange={(e) => setFormValues({ ...formValues, price: Number(e.target.value) })}
              className="mt-2"
            />
          </div>
          <div>
            <label className="text-sm font-medium text-text">الحالة</label>
            <select
              className="mt-2 w-full rounded-xl border border-border px-4 py-3 text-sm"
              value={formValues.status}
              onChange={(e) => setFormValues({ ...formValues, status: e.target.value as Product["status"] })}
            >
              <option value="active">نشط</option>
              <option value="inactive">مخفي</option>
            </select>
          </div>
          <div className="flex justify-end gap-3 pt-3">
            <Button variant="secondary" onClick={() => setEditingProduct(null)}>
              إلغاء
            </Button>
            <Button onClick={handleSave} loading={updateProduct.isPending}>
              حفظ التعديلات
            </Button>
          </div>
        </div>
      </Dialog>
    </div>
  );
}
