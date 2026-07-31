import { useState } from "react";
import { useStores, useApproveStore, useRejectStore } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Search, Star } from "lucide-react";
import { formatDate } from "@/lib/utils";

const statusLabels: Record<string, string> = {
  active: "نشط",
  inactive: "غير نشط",
  pending: "قيد الانتظار",
  suspended: "معلق",
};

const statusVariants: Record<string, "success" | "secondary" | "warning" | "danger"> = {
  active: "success",
  inactive: "secondary",
  pending: "warning",
  suspended: "danger",
};

export default function StoresPage() {
  const { data: stores } = useStores();
  const approveStore = useApproveStore();
  const rejectStore = useRejectStore();
  const [search, setSearch] = useState("");

  const filtered = (stores || []).filter((s) =>
    s.name_ar.includes(search) || s.name_en.toLowerCase().includes(search.toLowerCase()) || (s.merchant_name || "").includes(search)
  );

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-text">المتاجر</h1>

      <Card className="p-6">
        <div className="flex items-center gap-4 mb-6">
          <div className="relative flex-1 min-w-[250px]">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
            <Input
              placeholder="بحث بالاسم أو اسم التاجر..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pr-10"
            />
          </div>
        </div>

        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>الشعار</TableHead>
              <TableHead>اسم المتجر</TableHead>
              <TableHead>التاجر</TableHead>
              <TableHead>التقييم</TableHead>
              <TableHead>المنتجات</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>تاريخ التسجيل</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((store) => (
              <TableRow key={store.id}>
                <TableCell>
                  <img src={store.logo_url} alt={store.name_ar} className="w-10 h-10 rounded-lg object-cover" />
                </TableCell>
                <TableCell className="font-medium">{store.name_ar}</TableCell>
                <TableCell>{store.merchant_name || "-"}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Star className="h-3.5 w-3.5 text-accent fill-accent" />
                    <span className="text-sm">{store.rating || "-"}</span>
                  </div>
                </TableCell>
                <TableCell>{store.product_count || 0}</TableCell>
                <TableCell>
                  <Badge variant={statusVariants[store.status]}>{statusLabels[store.status]}</Badge>
                </TableCell>
                <TableCell>{formatDate(store.created_at)}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    {store.status === "active" && (
                      <Button size="sm" variant="outline-danger" onClick={() => rejectStore.mutate(store.id)}>
                        تعليق
                      </Button>
                    )}
                    {store.status === "suspended" && (
                      <Button size="sm" onClick={() => approveStore.mutate(store.id)}>
                        تفعيل
                      </Button>
                    )}
                    {store.status === "pending" && (
                      <>
                        <Button size="sm" onClick={() => approveStore.mutate(store.id)}>تفعيل</Button>
                        <Button size="sm" variant="outline-danger" onClick={() => rejectStore.mutate(store.id)}>تعليق</Button>
                      </>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}
