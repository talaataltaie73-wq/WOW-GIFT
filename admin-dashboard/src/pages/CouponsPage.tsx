import { useState } from "react";
import { useCoupons, useCreateCoupon, useUpdateCoupon } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select } from "@/components/ui/select";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Plus, Pencil } from "lucide-react";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { Coupon } from "@/types";

export default function CouponsPage() {
  const { data: coupons } = useCoupons();
  const createCoupon = useCreateCoupon();
  const updateCoupon = useUpdateCoupon();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Coupon | null>(null);
  const [form, setForm] = useState({
    code: "", type: "percentage" as "percentage" | "fixed", value: "", min_order: "", usage_limit: "", expiry_date: "", is_active: true,
  });

  const openCreate = () => {
    setEditing(null);
    setForm({ code: "", type: "percentage", value: "", min_order: "", usage_limit: "", expiry_date: "", is_active: true });
    setDialogOpen(true);
  };

  const openEdit = (coupon: Coupon) => {
    setEditing(coupon);
    setForm({
      code: coupon.code,
      type: coupon.type,
      value: String(coupon.value),
      min_order: String(coupon.min_order),
      usage_limit: String(coupon.usage_limit),
      expiry_date: coupon.expiry_date.split("T")[0],
      is_active: coupon.is_active,
    });
    setDialogOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const data = {
      code: form.code,
      type: form.type,
      value: parseFloat(form.value),
      min_order: parseFloat(form.min_order),
      usage_limit: parseInt(form.usage_limit),
      expiry_date: form.expiry_date + "T23:59:59Z",
      is_active: form.is_active,
    };
    if (editing) {
      updateCoupon.mutate({ id: editing.id, data }, { onSuccess: () => setDialogOpen(false) });
    } else {
      createCoupon.mutate(data, { onSuccess: () => setDialogOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-text">الكوبونات</h1>
        <Button onClick={openCreate} className="gap-2"><Plus className="h-4 w-4" />إضافة كوبون</Button>
      </div>

      <Card className="p-6">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الكود</TableHead>
              <TableHead>النوع</TableHead>
              <TableHead>القيمة</TableHead>
              <TableHead>الحد الأدنى للطلب</TableHead>
              <TableHead>الاستخدام</TableHead>
              <TableHead>تاريخ الانتهاء</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(coupons || []).map((coupon) => (
              <TableRow key={coupon.id}>
                <TableCell>
                  <span className="font-mono font-bold text-primary bg-primary/5 px-2 py-1 rounded">{coupon.code}</span>
                </TableCell>
                <TableCell>{coupon.type === "percentage" ? "نسبة مئوية" : "مبلغ ثابت"}</TableCell>
                <TableCell className="font-medium">
                  {coupon.type === "percentage" ? `%${coupon.value}` : formatCurrency(coupon.value)}
                </TableCell>
                <TableCell>{formatCurrency(coupon.min_order)}</TableCell>
                <TableCell>
                  <span className="text-text-secondary">{coupon.used_count}</span>
                  <span className="text-text-secondary/50"> / {coupon.usage_limit}</span>
                </TableCell>
                <TableCell>{formatDate(coupon.expiry_date)}</TableCell>
                <TableCell>
                  <Badge variant={coupon.is_active ? "success" : "secondary"}>
                    {coupon.is_active ? "نشط" : "غير نشط"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Button size="sm" variant="ghost" onClick={() => openEdit(coupon)}><Pencil className="h-4 w-4" /></Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)}>
        <DialogHeader>
          <DialogTitle>{editing ? "تعديل الكوبون" : "إضافة كوبون جديد"}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input label="الكود" value={form.code} onChange={(e) => setForm({ ...form, code: e.target.value.toUpperCase() })} dir="ltr" required />
          <Select
            label="النوع"
            options={[
              { value: "percentage", label: "نسبة مئوية" },
              { value: "fixed", label: "مبلغ ثابت (د.ع)" },
            ]}
            value={form.type}
            onChange={(e) => setForm({ ...form, type: e.target.value as "percentage" | "fixed" })}
          />
          <Input label={form.type === "percentage" ? "النسبة (%)" : "المبلغ (د.ع)"} type="number" value={form.value} onChange={(e) => setForm({ ...form, value: e.target.value })} required />
          <Input label="الحد الأدنى للطلب (د.ع)" type="number" value={form.min_order} onChange={(e) => setForm({ ...form, min_order: e.target.value })} required />
          <Input label="حد الاستخدام" type="number" value={form.usage_limit} onChange={(e) => setForm({ ...form, usage_limit: e.target.value })} required />
          <Input label="تاريخ الانتهاء" type="date" value={form.expiry_date} onChange={(e) => setForm({ ...form, expiry_date: e.target.value })} required />
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
            <Button type="submit" loading={createCoupon.isPending || updateCoupon.isPending}>
              {editing ? "حفظ التعديلات" : "إضافة"}
            </Button>
            <Button type="button" variant="secondary" onClick={() => setDialogOpen(false)}>إلغاء</Button>
          </div>
        </form>
      </Dialog>
    </div>
  );
}
