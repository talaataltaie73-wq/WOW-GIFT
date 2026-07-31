import { useDashboardStats } from "@/hooks/useApi";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Users, Store, ShoppingCart, TrendingUp, ArrowUpLeft, CheckCircle, X } from "lucide-react";
import { formatCurrency, formatDate } from "@/lib/utils";
import { useNavigate } from "react-router-dom";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";

export default function OverviewPage() {
  const { data: stats } = useDashboardStats();
  const navigate = useNavigate();

  if (!stats) return <div className="flex items-center justify-center h-64"><div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" /></div>;

  const kpiCards = [
    { label: "إجمالي المستخدمين", value: stats.total_users.toLocaleString("ar-IQ"), trend: stats.users_trend, icon: Users, color: "bg-primary/10 text-primary" },
    { label: "المتاجر النشطة", value: stats.active_stores.toLocaleString("ar-IQ"), trend: stats.stores_trend, icon: Store, color: "bg-primary/10 text-primary" },
    { label: "إجمالي الطلبات", value: stats.total_orders.toLocaleString("ar-IQ"), trend: stats.orders_trend, icon: ShoppingCart, color: "bg-primary/10 text-primary" },
    { label: "إيرادات المنصة (IQD)", value: stats.platform_revenue.toLocaleString("ar-IQ"), trend: stats.revenue_trend, icon: TrendingUp, color: "bg-primary/10 text-primary" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-text">نظرة عامة</h1>
        <p className="text-text-secondary text-sm mt-1">👋 مرحباً بك في لوحة إدارة Wow Gift</p>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {kpiCards.map((kpi) => (
          <Card key={kpi.label} className="p-5">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-sm text-text-secondary mb-1">{kpi.label}</p>
                <p className="text-2xl font-bold text-text">{kpi.value}</p>
                <div className="flex items-center gap-1 mt-2">
                  <ArrowUpLeft className="h-3.5 w-3.5 text-accent" />
                  <span className="text-xs font-medium text-accent">%{kpi.trend}+</span>
                  <span className="text-xs text-text-secondary">عن الشهر الماضي</span>
                </div>
              </div>
              <div className={`w-10 h-10 rounded-xl ${kpi.color} flex items-center justify-center`}>
                <kpi.icon className="h-5 w-5" />
              </div>
            </div>
          </Card>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Area Chart */}
        <Card className="lg:col-span-2 p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-base font-bold text-text">الطلبات خلال آخر 12 شهر</h3>
            <div className="flex items-center gap-2">
              <span className="w-3 h-3 rounded-full bg-primary" />
              <span className="text-xs text-text-secondary">عدد الطلبات</span>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={280}>
            <AreaChart data={stats.monthly_orders}>
              <defs>
                <linearGradient id="orderGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#0F766E" stopOpacity={0.3} />
                  <stop offset="95%" stopColor="#0F766E" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="month" tick={{ fontSize: 11, fill: "#6B7280" }} />
              <YAxis tick={{ fontSize: 11, fill: "#6B7280" }} />
              <Tooltip contentStyle={{ borderRadius: 12, border: "1px solid #E5E7EB", fontFamily: "Cairo" }} />
              <Area type="monotone" dataKey="orders" stroke="#0F766E" strokeWidth={2} fill="url(#orderGradient)" />
            </AreaChart>
          </ResponsiveContainer>
        </Card>

        {/* Donut Chart */}
        <Card className="p-6">
          <h3 className="text-base font-bold text-text mb-4">حالة الطلبات</h3>
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie
                data={stats.order_status_distribution}
                cx="50%"
                cy="50%"
                innerRadius={55}
                outerRadius={80}
                paddingAngle={3}
                dataKey="value"
              >
                {stats.order_status_distribution.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 12, border: "1px solid #E5E7EB", fontFamily: "Cairo" }} />
            </PieChart>
          </ResponsiveContainer>
          <div className="text-center -mt-4 mb-3">
            <p className="text-2xl font-bold text-text">{stats.total_orders.toLocaleString("ar-IQ")}</p>
            <p className="text-xs text-text-secondary">إجمالي الطلبات</p>
          </div>
          <div className="space-y-2">
            {stats.order_status_distribution.map((item) => (
              <div key={item.name} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-2">
                  <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: item.color }} />
                  <span className="text-text-secondary">{item.name}</span>
                </div>
                <span className="font-medium text-text">{item.value.toLocaleString("ar-IQ")} ({((item.value / stats.total_orders) * 100).toFixed(1)}%)</span>
              </div>
            ))}
          </div>
        </Card>
      </div>

      {/* Pending Approvals Table */}
      <Card className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <CheckCircle className="h-5 w-5 text-primary" />
            <h3 className="text-base font-bold text-text">طلبات اعتماد المتاجر المعلقة</h3>
          </div>
        </div>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>#</TableHead>
              <TableHead>اسم المتجر</TableHead>
              <TableHead>اسم صاحب المتجر</TableHead>
              <TableHead>البريد الإلكتروني</TableHead>
              <TableHead>تاريخ الطلب</TableHead>
              <TableHead>الحالة</TableHead>
              <TableHead>الإجراءات</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {stats.pending_approvals.slice(0, 5).map((store, idx) => (
              <TableRow key={store.id}>
                <TableCell className="font-medium">{idx + 1}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-lg bg-primary/10 flex items-center justify-center">
                      <Store className="h-4 w-4 text-primary" />
                    </div>
                    <span className="font-medium">{store.name_ar}</span>
                  </div>
                </TableCell>
                <TableCell>{store.merchant_name}</TableCell>
                <TableCell dir="ltr" className="text-left">{store.email}</TableCell>
                <TableCell>{formatDate(store.created_at)}</TableCell>
                <TableCell><Badge variant="warning">جديد</Badge></TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    <Button size="sm" className="gap-1"><CheckCircle className="h-3.5 w-3.5" />اعتماد</Button>
                    <Button size="sm" variant="outline-danger" className="gap-1"><X className="h-3.5 w-3.5" />رفض</Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <button
          onClick={() => navigate("/store-approvals")}
          className="text-sm text-primary font-medium mt-4 hover:underline flex items-center gap-1"
        >
          عرض جميع طلبات الاعتماد
          <span>&larr;</span>
        </button>
      </Card>
    </div>
  );
}
