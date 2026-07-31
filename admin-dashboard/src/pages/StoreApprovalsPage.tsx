import React, { useState } from "react";
import { useStores, useApproveStore, useRejectStore } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Search, ChevronDown, ChevronUp, Download, CheckCircle2 } from "lucide-react";
import { formatDateTime } from "@/lib/utils";

type FilterStatus = "all" | "pending" | "active" | "rejected";

const filterChips: { value: FilterStatus; label: string }[] = [
  { value: "all", label: "الكل" },
  { value: "pending", label: "قيد الانتظار" },
  { value: "active", label: "مقبول" },
  { value: "rejected", label: "مرفوض" },
];

const statusLabels: Record<string, string> = {
  active: "معتمد",
  pending: "قيد المراجعة",
  rejected: "مرفوض",
  suspended: "معلق",
  inactive: "غير نشط",
};

const statusVariants: Record<string, "success" | "warning" | "danger" | "secondary"> = {
  active: "success",
  pending: "warning",
  rejected: "danger",
  suspended: "danger",
  inactive: "secondary",
};

export default function StoreApprovalsPage() {
  const { data: stores } = useStores();
  const approveStore = useApproveStore();
  const rejectStore = useRejectStore();
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<FilterStatus>("all");
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const perPage = 10;

  const filtered = (stores || []).filter((s) => {
    const matchSearch = s.name_ar.includes(search) || (s.merchant_name || "").includes(search) || s.phone.includes(search);
    const matchFilter = filter === "all" || s.status === filter;
    return matchSearch && matchFilter;
  });

  const totalPages = Math.ceil(filtered.length / perPage);
  const paginated = filtered.slice((page - 1) * perPage, page * perPage);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text">إدارة الموافقات</h1>
        <p className="text-text-secondary text-sm mt-1">مراجعة واعتماد طلبات المتاجر الجديدة</p>
      </div>

      <Card className="p-6">
        {/* Search + Filters */}
        <div className="flex flex-wrap items-center gap-4 mb-6">
          <div className="relative flex-1 min-w-[300px]">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
            <Input
              placeholder="ابحث باسم المتجر أو اسم التاجر أو رقم الجوال..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pr-10"
            />
          </div>
          <div className="flex items-center gap-2">
            <span className="text-sm text-text-secondary">الحالة</span>
            {filterChips.map((chip) => (
              <button
                key={chip.value}
                onClick={() => { setFilter(chip.value); setPage(1); }}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors border ${
                  filter === chip.value
                    ? "border-accent text-accent bg-accent/5"
                    : "border-border text-text-secondary hover:bg-surface"
                }`}
              >
                {chip.value !== "all" && (
                  <span className={`inline-block w-2 h-2 rounded-full mr-1.5 ${
                    chip.value === "pending" ? "bg-warning" : chip.value === "active" ? "bg-success" : "bg-danger"
                  }`} />
                )}
                {chip.label}
              </button>
            ))}
          </div>
        </div>

        {/* Table */}
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>شعار المتجر</TableHead>
              <TableHead>اسم المتجر</TableHead>
              <TableHead>اسم التاجر</TableHead>
              <TableHead>رقم الجوال</TableHead>
              <TableHead>تاريخ التسجيل</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {paginated.map((store) => (
              <React.Fragment key={store.id}>
                <TableRow className="cursor-pointer" onClick={() => setExpandedId(expandedId === store.id ? null : store.id)}>
                  <TableCell>
                    <img src={store.logo_url} alt={store.name_ar} className="w-12 h-12 rounded-xl object-cover" />
                  </TableCell>
                  <TableCell className="font-medium">{store.name_ar}</TableCell>
                  <TableCell>{store.merchant_name || "-"}</TableCell>
                  <TableCell dir="ltr" className="text-left">{store.phone}</TableCell>
                  <TableCell>{formatDateTime(store.created_at)}</TableCell>
                  <TableCell>
                    <Badge variant={statusVariants[store.status]}>
                      <span className={`inline-block w-2 h-2 rounded-full mr-1 ${
                        store.status === "pending" ? "bg-warning" : store.status === "active" ? "bg-success" : "bg-danger"
                      }`} />
                      {statusLabels[store.status]}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Button size="sm" onClick={(e) => { e.stopPropagation(); approveStore.mutate(store.id); }}>
                        اعتماد
                      </Button>
                      <Button size="sm" variant="outline-danger" onClick={(e) => { e.stopPropagation(); rejectStore.mutate(store.id); }}>
                        رفض
                      </Button>
                      {expandedId === store.id ? <ChevronUp className="h-4 w-4 text-text-secondary" /> : <ChevronDown className="h-4 w-4 text-text-secondary" />}
                    </div>
                  </TableCell>
                </TableRow>
                {expandedId === store.id && (
                  <TableRow>
                    <TableCell colSpan={7} className="bg-surface/50 p-6">
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        {/* Terms */}
                        <div>
                          <h4 className="font-bold text-sm mb-3">موافقة الشروط والأحكام</h4>
                          <div className="space-y-2">
                            {[
                              { label: "أقر بأنني قرأت وافقت على شروط وأحكام المنصة", checked: store.terms_accepted },
                              { label: "أتعهد بصحة المعلومات المقدمة", checked: store.info_accurate },
                              { label: "أوافق على سياسة الخصوصية", checked: store.privacy_accepted },
                            ].map((item) => (
                              <div key={item.label} className="flex items-center gap-2">
                                <CheckCircle2 className={`h-5 w-5 ${item.checked ? "text-accent" : "text-gray-300"}`} />
                                <span className="text-sm text-text-secondary">{item.label}</span>
                              </div>
                            ))}
                          </div>
                        </div>
                        {/* Commission */}
                        <div className="text-center">
                          <h4 className="font-bold text-sm mb-3">نسبة العمولة</h4>
                          <p className="text-4xl font-bold text-primary">%10</p>
                          <p className="text-xs text-text-secondary mt-2">تطبق نسبة العمولة على جميع الطلبات بعد خصم العروض والخصومات</p>
                        </div>
                        {/* Documents */}
                        <div>
                          <h4 className="font-bold text-sm mb-3">مستندات المتجر</h4>
                          <div className="space-y-2">
                            {(store.documents || []).map((doc) => (
                              <div key={doc.name} className="flex items-center justify-between bg-white rounded-lg p-2 border border-border">
                                <div className="flex items-center gap-2">
                                  <Download className="h-4 w-4 text-text-secondary" />
                                  <span className="text-sm">{doc.name}</span>
                                </div>
                                <Badge variant={doc.status === "approved" ? "success" : doc.status === "pending" ? "warning" : "danger"}>
                                  {doc.status === "approved" ? "معتمد" : doc.status === "pending" ? "قيد المراجعة" : "مرفوض"}
                                </Badge>
                              </div>
                            ))}
                          </div>
                        </div>
                      </div>
                    </TableCell>
                  </TableRow>
                )}
              </React.Fragment>
            ))}
          </TableBody>
        </Table>

        {/* Pagination */}
        <div className="flex items-center justify-between mt-6">
          <div className="flex items-center gap-2">
            <span className="text-sm text-text-secondary">عرض</span>
            <select className="border border-border rounded-lg px-2 py-1 text-sm" value={perPage} disabled>
              <option value={10}>10</option>
            </select>
            <span className="text-sm text-text-secondary">لكل صفحة</span>
          </div>
          <div className="text-sm text-text-secondary">
            {(page - 1) * perPage + 1} - {Math.min(page * perPage, filtered.length)} من {filtered.length} طلب
          </div>
          <div className="flex items-center gap-1">
            <button onClick={() => setPage(1)} disabled={page === 1} className="px-2 py-1 rounded text-sm disabled:opacity-30">&raquo;</button>
            <button onClick={() => setPage(page - 1)} disabled={page === 1} className="px-2 py-1 rounded text-sm disabled:opacity-30">&rsaquo;</button>
            {Array.from({ length: Math.min(totalPages, 3) }, (_, i) => i + 1).map((p) => (
              <button
                key={p}
                onClick={() => setPage(p)}
                className={`w-8 h-8 rounded-lg text-sm font-medium ${
                  page === p ? "bg-primary text-white" : "hover:bg-surface"
                }`}
              >
                {p}
              </button>
            ))}
            <button onClick={() => setPage(page + 1)} disabled={page === totalPages} className="px-2 py-1 rounded text-sm disabled:opacity-30">&lsaquo;</button>
            <button onClick={() => setPage(totalPages)} disabled={page === totalPages} className="px-2 py-1 rounded text-sm disabled:opacity-30">&laquo;</button>
          </div>
        </div>
      </Card>
    </div>
  );
}
