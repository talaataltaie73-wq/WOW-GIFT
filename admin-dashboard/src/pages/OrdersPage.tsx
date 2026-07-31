import { useState } from "react";
import { useOrders, useUpdateOrderStatus } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Search, Eye, Gift, MessageSquare, UserX } from "lucide-react";
import { formatCurrency, formatDateTime } from "@/lib/utils";
import type { Order, OrderStatus } from "@/types";

const statusConfig: Record<OrderStatus, { label: string; variant: "warning" | "info" | "accent" | "default" | "success" | "danger" }> = {
  pending_approval: { label: "بانتظار الموافقة", variant: "warning" },
  accepted: { label: "تم قبول الطلب", variant: "info" },
  preparing: { label: "جاري التجهيز", variant: "accent" },
  out_for_delivery: { label: "خرج مع المندوب", variant: "default" },
  delivered: { label: "تم التسليم", variant: "success" },
  cancelled: { label: "تم الإلغاء", variant: "danger" },
};

const statusFlow: Record<string, OrderStatus | null> = {
  pending_approval: "accepted",
  accepted: "preparing",
  preparing: "out_for_delivery",
  out_for_delivery: "delivered",
  delivered: null,
  cancelled: null,
};

export default function OrdersPage() {
  const { data: orders } = useOrders();
  const updateStatus = useUpdateOrderStatus();
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);

  const filtered = (orders || []).filter((o) => {
    const matchSearch = o.order_number.includes(search) || o.customer_name.includes(search);
    const matchStatus = statusFilter === "all" || o.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const statusFilters = [
    { value: "all", label: "الكل" },
    { value: "pending_approval", label: "بانتظار الموافقة" },
    { value: "accepted", label: "تم قبول الطلب" },
    { value: "preparing", label: "جاري التجهيز" },
    { value: "out_for_delivery", label: "خرج مع المندوب" },
    { value: "delivered", label: "تم التسليم" },
    { value: "cancelled", label: "تم الإلغاء" },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-text">الطلبات</h1>

      <Card className="p-6">
        <div className="flex flex-wrap items-center gap-4 mb-6">
          <div className="relative flex-1 min-w-[250px]">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
            <Input placeholder="بحث برقم الطلب أو اسم العميل..." value={search} onChange={(e) => setSearch(e.target.value)} className="pr-10" />
          </div>
          <div className="flex flex-wrap gap-2">
            {statusFilters.map((f) => (
              <button
                key={f.value}
                onClick={() => setStatusFilter(f.value)}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition-colors border ${
                  statusFilter === f.value
                    ? "border-accent text-accent bg-accent/5"
                    : "border-border text-text-secondary hover:bg-surface"
                }`}
              >
                {f.label}
              </button>
            ))}
          </div>
        </div>

        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>رقم الطلب</TableHead>
              <TableHead>العميل</TableHead>
              <TableHead>المتجر</TableHead>
              <TableHead>المبلغ</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>التاريخ</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((order) => {
              const config = statusConfig[order.status];
              const nextStatus = statusFlow[order.status];
              return (
                <TableRow key={order.id}>
                  <TableCell className="font-medium" dir="ltr">{order.order_number}</TableCell>
                  <TableCell>{order.customer_name}</TableCell>
                  <TableCell>{order.store_name || "-"}</TableCell>
                  <TableCell>{formatCurrency(order.total)}</TableCell>
                  <TableCell><Badge variant={config.variant}>{config.label}</Badge></TableCell>
                  <TableCell>{formatDateTime(order.created_at)}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <Button size="sm" variant="ghost" onClick={() => setSelectedOrder(order)}>
                        <Eye className="h-4 w-4" />
                      </Button>
                      {nextStatus && (
                        <Button size="sm" onClick={() => updateStatus.mutate({ id: order.id, status: nextStatus })}>
                          {statusConfig[nextStatus].label}
                        </Button>
                      )}
                      {order.status !== "cancelled" && order.status !== "delivered" && (
                        <Button size="sm" variant="outline-danger" onClick={() => updateStatus.mutate({ id: order.id, status: "cancelled" })}>
                          إلغاء
                        </Button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </Card>

      {/* Order Detail Drawer */}
      <Dialog open={!!selectedOrder} onClose={() => setSelectedOrder(null)} className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>تفاصيل الطلب {selectedOrder?.order_number}</DialogTitle>
        </DialogHeader>
        {selectedOrder && (
          <div className="space-y-5">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-text-secondary">العميل</p>
                <p className="font-medium">{selectedOrder.customer_name}</p>
              </div>
              <div>
                <p className="text-text-secondary">الهاتف</p>
                <p className="font-medium" dir="ltr">{selectedOrder.customer_phone}</p>
              </div>
              <div>
                <p className="text-text-secondary">المتجر</p>
                <p className="font-medium">{selectedOrder.store_name}</p>
              </div>
              <div>
                <p className="text-text-secondary">الحالة</p>
                <Badge variant={statusConfig[selectedOrder.status].variant}>{statusConfig[selectedOrder.status].label}</Badge>
              </div>
              <div className="col-span-2">
                <p className="text-text-secondary">عنوان التوصيل</p>
                <p className="font-medium">{selectedOrder.delivery_address}</p>
              </div>
            </div>

            {/* Gift Customization */}
            {(selectedOrder.greeting_card || selectedOrder.private_message || selectedOrder.is_anonymous) && (
              <div className="bg-accent/5 rounded-xl p-4 space-y-3">
                <h4 className="font-bold text-sm flex items-center gap-2"><Gift className="h-4 w-4 text-accent" />تخصيص الهدية</h4>
                {selectedOrder.greeting_card && (
                  <div className="flex items-start gap-2">
                    <MessageSquare className="h-4 w-4 text-primary mt-0.5" />
                    <div>
                      <p className="text-xs text-text-secondary">بطاقة تهنئة</p>
                      <p className="text-sm">{selectedOrder.greeting_card}</p>
                    </div>
                  </div>
                )}
                {selectedOrder.private_message && (
                  <div className="flex items-start gap-2">
                    <MessageSquare className="h-4 w-4 text-info mt-0.5" />
                    <div>
                      <p className="text-xs text-text-secondary">رسالة خاصة</p>
                      <p className="text-sm">{selectedOrder.private_message}</p>
                    </div>
                  </div>
                )}
                {selectedOrder.is_anonymous && (
                  <div className="flex items-center gap-2">
                    <UserX className="h-4 w-4 text-warning" />
                    <span className="text-sm text-warning font-medium">هدية مجهولة المرسل</span>
                  </div>
                )}
              </div>
            )}

            {/* Items */}
            <div>
              <h4 className="font-bold text-sm mb-3">المنتجات</h4>
              <div className="space-y-2">
                {selectedOrder.items.map((item) => (
                  <div key={item.id} className="flex items-center justify-between bg-surface rounded-lg p-3">
                    <div>
                      <p className="text-sm font-medium">{item.product_name}</p>
                      <p className="text-xs text-text-secondary">الكمية: {item.quantity} × {formatCurrency(item.price)}</p>
                    </div>
                    <p className="font-bold text-sm">{formatCurrency(item.total)}</p>
                  </div>
                ))}
              </div>
              <div className="flex justify-between items-center mt-3 pt-3 border-t border-border">
                <span className="font-bold">الإجمالي</span>
                <span className="font-bold text-lg text-primary">{formatCurrency(selectedOrder.total)}</span>
              </div>
            </div>
          </div>
        )}
      </Dialog>
    </div>
  );
}
