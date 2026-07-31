import { useState } from "react";
import { useNotifications, useSendNotification } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select } from "@/components/ui/select";
import { Bell, ShoppingCart, Store, Users, Settings, Send } from "lucide-react";
import { formatDateTime } from "@/lib/utils";

const typeIcons: Record<string, typeof Bell> = {
  order: ShoppingCart,
  store: Store,
  user: Users,
  system: Settings,
};

const typeLabels: Record<string, string> = {
  order: "طلب",
  store: "متجر",
  user: "مستخدم",
  system: "نظام",
};

const typeVariants: Record<string, "info" | "accent" | "default" | "secondary"> = {
  order: "info",
  store: "accent",
  user: "default",
  system: "secondary",
};

export default function NotificationsPage() {
  const { data: notifications } = useNotifications();
  const sendNotification = useSendNotification();
  const [showCompose, setShowCompose] = useState(false);
  const [form, setForm] = useState({ title: "", message: "", target: "all" });

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    sendNotification.mutate(form, {
      onSuccess: () => {
        setForm({ title: "", message: "", target: "all" });
        setShowCompose(false);
      },
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-text">الإشعارات</h1>
        <Button onClick={() => setShowCompose(!showCompose)} className="gap-2">
          <Send className="h-4 w-4" />
          إرسال إشعار
        </Button>
      </div>

      {/* Compose Form */}
      {showCompose && (
        <Card className="p-6">
          <h3 className="font-bold text-text mb-4">إرسال إشعار جديد</h3>
          <form onSubmit={handleSend} className="space-y-4">
            <Input label="العنوان" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} required />
            <Textarea label="الرسالة" value={form.message} onChange={(e) => setForm({ ...form, message: e.target.value })} required />
            <Select
              label="الفئة المستهدفة"
              options={[
                { value: "all", label: "جميع المستخدمين" },
                { value: "customers", label: "العملاء فقط" },
                { value: "merchants", label: "التجار فقط" },
              ]}
              value={form.target}
              onChange={(e) => setForm({ ...form, target: e.target.value })}
            />
            <div className="flex gap-3">
              <Button type="submit" loading={sendNotification.isPending} className="gap-2">
                <Send className="h-4 w-4" />
                إرسال
              </Button>
              <Button type="button" variant="secondary" onClick={() => setShowCompose(false)}>إلغاء</Button>
            </div>
          </form>
        </Card>
      )}

      {/* Notifications List */}
      <div className="space-y-3">
        {(notifications || []).map((notif) => {
          const Icon = typeIcons[notif.type] || Bell;
          return (
            <Card key={notif.id} className={`p-4 flex items-start gap-4 ${!notif.is_read ? "border-r-4 border-r-primary" : ""}`}>
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${
                notif.type === "order" ? "bg-info/10 text-info" :
                notif.type === "store" ? "bg-accent/10 text-accent" :
                notif.type === "user" ? "bg-primary/10 text-primary" :
                "bg-gray-100 text-text-secondary"
              }`}>
                <Icon className="h-5 w-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <h4 className="font-bold text-sm text-text">{notif.title}</h4>
                  <Badge variant={typeVariants[notif.type]}>{typeLabels[notif.type]}</Badge>
                  {!notif.is_read && <span className="w-2 h-2 rounded-full bg-primary" />}
                </div>
                <p className="text-sm text-text-secondary">{notif.message}</p>
                <p className="text-xs text-text-secondary/60 mt-1">{formatDateTime(notif.created_at)}</p>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
