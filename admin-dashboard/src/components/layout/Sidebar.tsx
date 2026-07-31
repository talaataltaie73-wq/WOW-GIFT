import { NavLink } from "react-router-dom";
import {
  LayoutDashboard,
  Users,
  Store,
  CheckCircle,
  Package,
  ShoppingCart,
  Grid3X3,
  Megaphone,
  Ticket,
  BarChart3,
  Bell,
  LogOut,
  Gift,
} from "lucide-react";
import { useAuthStore } from "@/store/auth";
import { cn } from "@/lib/utils";

const navItems = [
  { to: "/", icon: LayoutDashboard, label: "نظرة عامة" },
  { to: "/users", icon: Users, label: "المستخدمون" },
  { to: "/stores", icon: Store, label: "المتاجر" },
  { to: "/store-approvals", icon: CheckCircle, label: "طلبات اعتماد المتاجر" },
  { to: "/products", icon: Package, label: "المنتجات" },
  { to: "/orders", icon: ShoppingCart, label: "الطلبات" },
  { to: "/categories", icon: Grid3X3, label: "التصنيفات" },
  { to: "/ads", icon: Megaphone, label: "الإعلانات" },
  { to: "/coupons", icon: Ticket, label: "الكوبونات" },
  { to: "/reports", icon: BarChart3, label: "التقارير" },
  { to: "/notifications", icon: Bell, label: "الإشعارات" },
];

export function Sidebar({ open, onClose }: { open?: boolean; onClose?: () => void }) {
  const { logout } = useAuthStore();

  return (
    <>
      {/* Overlay for mobile */}
      {open && (
        <div className="fixed inset-0 bg-black/40 z-30 lg:hidden" onClick={onClose} />
      )}
      <aside className={cn(
        "fixed right-0 top-0 h-screen w-64 bg-primary flex flex-col z-40 transition-transform duration-300",
        "lg:translate-x-0",
        open ? "translate-x-0" : "translate-x-full lg:translate-x-0"
      )}>
        {/* Logo */}
        <div className="p-6 pb-4">
          <div className="flex items-center gap-3 justify-center">
            <Gift className="h-8 w-8 text-accent" />
            <h1 className="font-extrabold text-accent text-2xl tracking-wide">Wow Gift</h1>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-3 space-y-0.5 overflow-y-auto">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === "/"}
              onClick={onClose}
              className={({ isActive }) =>
                cn(
                  "flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 relative",
                  isActive
                    ? "bg-white/15 text-white"
                    : "text-white/70 hover:bg-white/10 hover:text-white"
                )
              }
            >
              {({ isActive }) => (
                <>
                  {isActive && (
                    <span className="absolute right-0 top-1/2 -translate-y-1/2 w-1 h-6 bg-accent rounded-l-full" />
                  )}
                  <item.icon className="h-5 w-5 shrink-0" />
                  <span>{item.label}</span>
                </>
              )}
            </NavLink>
          ))}
        </nav>

        {/* Logout */}
        <div className="p-3">
          <button
            onClick={logout}
            className="flex items-center gap-3 w-full px-4 py-3 rounded-xl text-sm font-medium text-white bg-white/10 hover:bg-white/20 transition-colors"
          >
            <LogOut className="h-5 w-5" />
            <span>تسجيل الخروج</span>
          </button>
        </div>
      </aside>
    </>
  );
}
