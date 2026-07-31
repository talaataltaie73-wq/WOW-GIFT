import { useState } from "react";
import { useCategories, useCreateCategory, useUpdateCategory, useDeleteCategory } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Plus, Pencil, Trash2 } from "lucide-react";
import type { Category } from "@/types";

export default function CategoriesPage() {
  const { data: categories } = useCategories();
  const createCategory = useCreateCategory();
  const updateCategory = useUpdateCategory();
  const deleteCategory = useDeleteCategory();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Category | null>(null);
  const [form, setForm] = useState({ name_ar: "", name_en: "", icon: "", sort_order: "0", is_active: true });

  const openCreate = () => {
    setEditing(null);
    setForm({ name_ar: "", name_en: "", icon: "", sort_order: "0", is_active: true });
    setDialogOpen(true);
  };

  const openEdit = (cat: Category) => {
    setEditing(cat);
    setForm({
      name_ar: cat.name_ar,
      name_en: cat.name_en,
      icon: cat.icon || "",
      sort_order: String(cat.sort_order || 0),
      is_active: cat.is_active !== false,
    });
    setDialogOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const data = {
      name_ar: form.name_ar,
      name_en: form.name_en,
      icon: form.icon,
      sort_order: parseInt(form.sort_order),
      is_active: form.is_active,
    };
    if (editing) {
      updateCategory.mutate({ id: editing.id, data }, { onSuccess: () => setDialogOpen(false) });
    } else {
      createCategory.mutate(data, { onSuccess: () => setDialogOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-text">التصنيفات</h1>
        <Button onClick={openCreate} className="gap-2"><Plus className="h-4 w-4" />إضافة تصنيف</Button>
      </div>

      <Card className="p-6">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الأيقونة</TableHead>
              <TableHead>الاسم (عربي)</TableHead>
              <TableHead>الاسم (إنجليزي)</TableHead>
              <TableHead>الترتيب</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(categories || []).map((cat) => (
              <TableRow key={cat.id}>
                <TableCell className="text-2xl">{cat.icon || "📦"}</TableCell>
                <TableCell className="font-medium">{cat.name_ar}</TableCell>
                <TableCell dir="ltr" className="text-left">{cat.name_en}</TableCell>
                <TableCell>{cat.sort_order || 0}</TableCell>
                <TableCell>
                  <Badge variant={cat.is_active !== false ? "success" : "secondary"}>
                    {cat.is_active !== false ? "نشط" : "غير نشط"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button size="sm" variant="ghost" onClick={() => openEdit(cat)}><Pencil className="h-4 w-4" /></Button>
                    <Button size="sm" variant="ghost" className="text-danger" onClick={() => deleteCategory.mutate(cat.id)}><Trash2 className="h-4 w-4" /></Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)}>
        <DialogHeader>
          <DialogTitle>{editing ? "تعديل التصنيف" : "إضافة تصنيف جديد"}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input label="الاسم (عربي)" value={form.name_ar} onChange={(e) => setForm({ ...form, name_ar: e.target.value })} required />
          <Input label="الاسم (إنجليزي)" value={form.name_en} onChange={(e) => setForm({ ...form, name_en: e.target.value })} dir="ltr" required />
          <Input label="الأيقونة (إيموجي)" value={form.icon} onChange={(e) => setForm({ ...form, icon: e.target.value })} placeholder="🎁" />
          <Input label="الترتيب" type="number" value={form.sort_order} onChange={(e) => setForm({ ...form, sort_order: e.target.value })} />
          <div className="flex items-center gap-3">
            <label className="text-sm font-medium text-text">نشط</label>
            <button
              type="button"
              onClick={() => setForm({ ...form, is_active: !form.is_active })}
              className={`w-11 h-6 rounded-full transition-colors ${form.is_active ? "bg-primary" : "bg-gray-300"}`}
            >
              <span className={`block w-5 h-5 rounded-full bg-white shadow transition-transform ${form.is_active ? "-translate-x-5" : "-translate-x-0.5"}`} />
            </button>
          </div>
          <div className="flex gap-3 pt-2">
            <Button type="submit" loading={createCategory.isPending || updateCategory.isPending}>
              {editing ? "حفظ التعديلات" : "إضافة"}
            </Button>
            <Button type="button" variant="secondary" onClick={() => setDialogOpen(false)}>إلغاء</Button>
          </div>
        </form>
      </Dialog>
    </div>
  );
}
