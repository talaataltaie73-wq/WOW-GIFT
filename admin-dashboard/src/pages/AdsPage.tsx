import { useState } from "react";
import { useBanners, useCreateBanner, useUpdateBanner, useDeleteBanner } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Plus, Pencil, Trash2 } from "lucide-react";
import { formatDate } from "@/lib/utils";
import type { Banner } from "@/types";

export default function AdsPage() {
  const { data: banners } = useBanners();
  const createBanner = useCreateBanner();
  const updateBanner = useUpdateBanner();
  const deleteBanner = useDeleteBanner();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Banner | null>(null);
  const [form, setForm] = useState({ title: "", image_url: "", link_target: "", start_date: "", end_date: "", is_active: true });

  const openCreate = () => {
    setEditing(null);
    setForm({ title: "", image_url: "", link_target: "", start_date: "", end_date: "", is_active: true });
    setDialogOpen(true);
  };

  const openEdit = (banner: Banner) => {
    setEditing(banner);
    setForm({
      title: banner.title,
      image_url: banner.image_url,
      link_target: banner.link_target,
      start_date: banner.start_date.split("T")[0],
      end_date: banner.end_date.split("T")[0],
      is_active: banner.is_active,
    });
    setDialogOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const data = {
      title: form.title,
      image_url: form.image_url,
      link_target: form.link_target,
      start_date: form.start_date + "T00:00:00Z",
      end_date: form.end_date + "T23:59:59Z",
      is_active: form.is_active,
    };
    if (editing) {
      updateBanner.mutate({ id: editing.id, data }, { onSuccess: () => setDialogOpen(false) });
    } else {
      createBanner.mutate(data, { onSuccess: () => setDialogOpen(false) });
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-text">الإعلانات</h1>
        <Button onClick={openCreate} className="gap-2"><Plus className="h-4 w-4" />إضافة إعلان</Button>
      </div>

      <Card className="p-6">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الصورة</TableHead>
              <TableHead>العنوان</TableHead>
              <TableHead>الرابط</TableHead>
              <TableHead>تاريخ البداية</TableHead>
              <TableHead>تاريخ النهاية</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {(banners || []).map((banner) => (
              <TableRow key={banner.id}>
                <TableCell>
                  <img src={banner.image_url} alt={banner.title} className="w-24 h-10 rounded-lg object-cover" />
                </TableCell>
                <TableCell className="font-medium">{banner.title}</TableCell>
                <TableCell dir="ltr" className="text-left text-xs text-text-secondary">{banner.link_target}</TableCell>
                <TableCell>{formatDate(banner.start_date)}</TableCell>
                <TableCell>{formatDate(banner.end_date)}</TableCell>
                <TableCell>
                  <Badge variant={banner.is_active ? "success" : "secondary"}>
                    {banner.is_active ? "نشط" : "غير نشط"}
                  </Badge>
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button size="sm" variant="ghost" onClick={() => openEdit(banner)}><Pencil className="h-4 w-4" /></Button>
                    <Button size="sm" variant="ghost" className="text-danger" onClick={() => deleteBanner.mutate(banner.id)}><Trash2 className="h-4 w-4" /></Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)}>
        <DialogHeader>
          <DialogTitle>{editing ? "تعديل الإعلان" : "إضافة إعلان جديد"}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <Input label="العنوان" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} required />
          <Input label="رابط الصورة" value={form.image_url} onChange={(e) => setForm({ ...form, image_url: e.target.value })} dir="ltr" required />
          <Input label="الرابط المستهدف" value={form.link_target} onChange={(e) => setForm({ ...form, link_target: e.target.value })} dir="ltr" />
          <div className="grid grid-cols-2 gap-4">
            <Input label="تاريخ البداية" type="date" value={form.start_date} onChange={(e) => setForm({ ...form, start_date: e.target.value })} required />
            <Input label="تاريخ النهاية" type="date" value={form.end_date} onChange={(e) => setForm({ ...form, end_date: e.target.value })} required />
          </div>
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
            <Button type="submit" loading={createBanner.isPending || updateBanner.isPending}>
              {editing ? "حفظ التعديلات" : "إضافة"}
            </Button>
            <Button type="button" variant="secondary" onClick={() => setDialogOpen(false)}>إلغاء</Button>
          </div>
        </form>
      </Dialog>
    </div>
  );
}
