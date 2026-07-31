import { useReportData } from "@/hooks/useApi";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Table, TableHeader, TableBody, TableRow, TableHead, TableCell } from "@/components/ui/table";
import { Download, Calendar, Info, TrendingUp } from "lucide-react";
import { formatCurrency } from "@/lib/utils";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  Legend,
} from "recharts";

export default function ReportsPage() {
  const { data: report } = useReportData();

  if (!report) return <div className="flex items-center justify-center h-64"><div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full" /></div>;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-text">التقارير والإحصائيات</h1>
          <p className="text-text-secondary text-sm mt-1">نظرة شاملة على أداء المنصة والمبيعات</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center gap-2 px-4 py-2 rounded-xl border border-border text-sm font-medium hover:bg-surface transition-colors">
            <Calendar className="h-4 w-4 text-accent" />
            <span>2025/05/01 - 2025/05/31</span>
          </button>
          <Button variant="secondary" className="gap-2">
            <Download className="h-4 w-4" />
            تصدير التقرير
          </Button>
        </div>
      </div>

      {/* Top Row: Revenue Chart + Top Products + Sales by Occasion */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Revenue Over Time */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-bold text-text flex items-center gap-1">الإيرادات على مدى الوقت <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          </div>
          <ResponsiveContainer width="100%" height={220}>
            <LineChart data={report.revenue_over_time}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
              <XAxis dataKey="date" tick={{ fontSize: 10, fill: "#6B7280" }} />
              <YAxis tick={{ fontSize: 10, fill: "#6B7280" }} tickFormatter={(v) => `${(v / 1000000).toFixed(0)}M`} />
              <Tooltip contentStyle={{ borderRadius: 12, border: "1px solid #E5E7EB", fontFamily: "Cairo" }} formatter={(value) => formatCurrency(Number(value))} />
              <Line type="monotone" dataKey="revenue" stroke="#0F766E" strokeWidth={2} dot={{ fill: "#D4AF37", r: 4 }} activeDot={{ r: 6, fill: "#D4AF37" }} />
            </LineChart>
          </ResponsiveContainer>
          <div className="flex items-center justify-between mt-4 pt-4 border-t border-border">
            <div>
              <p className="text-xs text-text-secondary">إجمالي الإيرادات</p>
              <p className="text-lg font-bold text-text">{formatCurrency(report.total_revenue)}</p>
            </div>
            <div className="flex items-center gap-1 text-success text-sm font-medium">
              <TrendingUp className="h-4 w-4" />
              18.7%
              <span className="text-text-secondary text-xs">مقارنة بالفترة السابقة</span>
            </div>
          </div>
        </Card>

        {/* Top Products */}
        <Card className="p-6">
          <h3 className="text-sm font-bold text-text flex items-center gap-1 mb-4">أفضل المنتجات مبيعاً <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={report.top_products} layout="vertical" margin={{ left: 0, right: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" horizontal={false} />
              <XAxis type="number" tick={{ fontSize: 10, fill: "#6B7280" }} />
              <YAxis type="category" dataKey="name" tick={{ fontSize: 10, fill: "#6B7280" }} width={100} />
              <Tooltip contentStyle={{ borderRadius: 12, border: "1px solid #E5E7EB", fontFamily: "Cairo" }} />
              <Bar dataKey="sales" fill="#0F766E" radius={[0, 4, 4, 0]} barSize={20} />
            </BarChart>
          </ResponsiveContainer>
          <button className="text-sm text-primary font-medium mt-2 hover:underline flex items-center gap-1">
            عرض كل المنتجات <span>&larr;</span>
          </button>
        </Card>

        {/* Sales by Occasion */}
        <Card className="p-6">
          <h3 className="text-sm font-bold text-text flex items-center gap-1 mb-4">المبيعات حسب المناسبة <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          <ResponsiveContainer width="100%" height={200}>
            <PieChart>
              <Pie
                data={report.sales_by_occasion}
                cx="50%"
                cy="50%"
                innerRadius={50}
                outerRadius={75}
                paddingAngle={3}
                dataKey="value"
              >
                {report.sales_by_occasion.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              <Tooltip contentStyle={{ borderRadius: 12, border: "1px solid #E5E7EB", fontFamily: "Cairo" }} formatter={(value) => `${value}%`} />
            </PieChart>
          </ResponsiveContainer>
          <div className="text-center -mt-2 mb-3">
            <p className="text-lg font-bold text-text">{formatCurrency(report.total_revenue)}</p>
            <p className="text-xs text-text-secondary">إجمالي المبيعات IQD</p>
          </div>
          <div className="grid grid-cols-2 gap-1">
            {report.sales_by_occasion.map((item) => (
              <div key={item.name} className="flex items-center gap-1.5 text-xs">
                <span className="w-2 h-2 rounded-full" style={{ backgroundColor: item.color }} />
                <span className="text-text-secondary">{item.name}</span>
                <span className="font-medium mr-auto">{item.value}%</span>
              </div>
            ))}
          </div>
          <button className="text-sm text-primary font-medium mt-3 hover:underline flex items-center gap-1">
            عرض كل المناسبات <span>&larr;</span>
          </button>
        </Card>
      </div>

      {/* Bottom Row: Top Stores + Commission + Coupon Usage */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Top Stores */}
        <Card className="p-6">
          <h3 className="text-sm font-bold text-text flex items-center gap-1 mb-4">المتاجر الأعلى أداءً <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          <div className="space-y-3">
            {report.top_stores.map((store) => (
              <div key={store.rank} className="flex items-center gap-3">
                <span className={`w-7 h-7 rounded-full flex items-center justify-center text-sm font-bold ${
                  store.rank <= 3 ? "bg-accent/10 text-accent" : "bg-surface text-text-secondary"
                }`}>
                  {store.rank}
                </span>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{store.name}</p>
                </div>
                <div className="text-left text-xs">
                  <p className="text-text-secondary">{store.orders.toLocaleString("ar-IQ")}</p>
                </div>
                <div className="text-left text-xs min-w-[90px]">
                  <p className="font-medium">{formatCurrency(store.revenue)}</p>
                </div>
              </div>
            ))}
          </div>
          <div className="flex items-center justify-between text-xs text-text-secondary mt-3 pt-3 border-t border-border">
            <span>المتجر</span>
            <span>الطلبات</span>
            <span>الإيرادات (IQD)</span>
          </div>
          <button className="text-sm text-primary font-medium mt-3 hover:underline flex items-center gap-1">
            عرض كل المتاجر <span>&larr;</span>
          </button>
        </Card>

        {/* Commission Card */}
        <Card className="p-6 flex flex-col items-center justify-center text-center">
          <h3 className="text-sm font-bold text-text flex items-center gap-1 mb-6">إجمالي العمولات المكتسبة <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          <p className="text-xs text-text-secondary mb-1">الفترة المحددة</p>
          <p className="text-4xl font-extrabold text-accent mb-2">{report.total_commission.toLocaleString("ar-IQ")} <span className="text-lg">IQD</span></p>
          <div className="flex items-center gap-4 mt-4 text-sm">
            <div>
              <p className="text-text-secondary text-xs">متوسط العمولة لكل طلب</p>
              <p className="font-bold">{formatCurrency(report.avg_commission_per_order)}</p>
            </div>
          </div>
          <div className="flex items-center gap-1 text-success text-sm font-medium mt-4">
            <TrendingUp className="h-4 w-4" />
            {report.commission_trend}%
            <span className="text-text-secondary text-xs">مقارنة بالفترة السابقة</span>
          </div>
          <button className="text-sm text-primary font-medium mt-4 hover:underline flex items-center gap-1">
            تفاصيل العمولات <span>&larr;</span>
          </button>
        </Card>

        {/* Coupon Usage */}
        <Card className="p-6">
          <h3 className="text-sm font-bold text-text flex items-center gap-1 mb-4">استخدام الكوبونات <Info className="h-3.5 w-3.5 text-text-secondary" /></h3>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>الكوبون</TableHead>
                <TableHead>عدد الاستخدام</TableHead>
                <TableHead>مجموع الخصم (IQD)</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {report.coupon_usage.map((c) => (
                <TableRow key={c.code}>
                  <TableCell className="font-mono font-bold text-primary">{c.code}</TableCell>
                  <TableCell>{c.usage_count.toLocaleString("ar-IQ")}</TableCell>
                  <TableCell>{formatCurrency(c.total_discount)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
          <button className="text-sm text-primary font-medium mt-3 hover:underline flex items-center gap-1">
            عرض كل الكوبونات <span>&larr;</span>
          </button>
        </Card>
      </div>
    </div>
  );
}
