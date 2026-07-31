import { useState } from "react";
import { useUsers, useToggleUserStatus } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Dialog, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Search, Eye } from "lucide-react";
import { formatDate } from "@/lib/utils";
import type { User } from "@/types";

const roleLabels: Record<string, string> = {
  customer: "عميل",
  merchant: "تاجر",
  admin: "مدير",
};

const roleVariants: Record<string, "default" | "accent" | "info"> = {
  customer: "info",
  merchant: "accent",
  admin: "default",
};

export default function UsersPage() {
  const { data: users } = useUsers();
  const toggleStatus = useToggleUserStatus();
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [selectedUser, setSelectedUser] = useState<User | null>(null);

  const filtered = (users || []).filter((u) => {
    const matchSearch = u.name.includes(search) || u.email.includes(search) || (u.phone || "").includes(search);
    const matchRole = roleFilter === "all" || u.role === roleFilter;
    return matchSearch && matchRole;
  });

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-text">المستخدمون</h1>

      <Card className="p-6">
        <div className="flex flex-wrap items-center gap-4 mb-6">
          <div className="relative flex-1 min-w-[250px]">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-text-secondary" />
            <Input
              placeholder="بحث بالاسم أو البريد أو الهاتف..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pr-10"
            />
          </div>
          <div className="flex gap-2">
            {[
              { value: "all", label: "الكل" },
              { value: "customer", label: "عملاء" },
              { value: "merchant", label: "تجار" },
              { value: "admin", label: "مديرون" },
            ].map((f) => (
              <button
                key={f.value}
                onClick={() => setRoleFilter(f.value)}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors ${
                  roleFilter === f.value
                    ? "bg-primary text-white"
                    : "bg-surface text-text-secondary hover:bg-gray-100 border border-border"
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
              <TableHead>الاسم</TableHead>
              <TableHead>البريد الإلكتروني</TableHead>
              <TableHead>الهاتف</TableHead>
              <TableHead>الدور</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>تاريخ التسجيل</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filtered.map((user) => (
              <TableRow key={user.id}>
                <TableCell className="font-medium">{user.name}</TableCell>
                <TableCell dir="ltr" className="text-left">{user.email}</TableCell>
                <TableCell dir="ltr" className="text-left">{user.phone || "-"}</TableCell>
                <TableCell>
                  <Badge variant={roleVariants[user.role] || "default"}>{roleLabels[user.role]}</Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={user.is_active ? "success" : "danger"}>
                    {user.is_active ? "نشط" : "محظور"}
                  </Badge>
                </TableCell>
                <TableCell>{user.created_at ? formatDate(user.created_at) : "-"}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button size="sm" variant="ghost" onClick={() => setSelectedUser(user)}>
                      <Eye className="h-4 w-4" />
                    </Button>
                    {user.role !== "admin" && (
                      <Button
                        size="sm"
                        variant={user.is_active ? "outline-danger" : "default"}
                        onClick={() => toggleStatus.mutate({ id: user.id, is_active: !user.is_active })}
                      >
                        {user.is_active ? "حظر" : "تفعيل"}
                      </Button>
                    )}
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      {/* User Detail Drawer */}
      <Dialog open={!!selectedUser} onClose={() => setSelectedUser(null)}>
        <DialogHeader>
          <DialogTitle>تفاصيل المستخدم</DialogTitle>
        </DialogHeader>
        {selectedUser && (
          <div className="space-y-4">
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center">
                <span className="text-primary font-bold text-xl">{selectedUser.name.charAt(0)}</span>
              </div>
              <div>
                <h3 className="font-bold text-text">{selectedUser.name}</h3>
                <p className="text-sm text-text-secondary">{selectedUser.email}</p>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p className="text-text-secondary">الهاتف</p>
                <p className="font-medium" dir="ltr">{selectedUser.phone || "-"}</p>
              </div>
              <div>
                <p className="text-text-secondary">الدور</p>
                <p className="font-medium">{roleLabels[selectedUser.role]}</p>
              </div>
              <div>
                <p className="text-text-secondary">الحالة</p>
                <Badge variant={selectedUser.is_active ? "success" : "danger"}>
                  {selectedUser.is_active ? "نشط" : "محظور"}
                </Badge>
              </div>
              <div>
                <p className="text-text-secondary">تاريخ التسجيل</p>
                <p className="font-medium">{selectedUser.created_at ? formatDate(selectedUser.created_at) : "-"}</p>
              </div>
            </div>
          </div>
        )}
      </Dialog>
    </div>
  );
}
