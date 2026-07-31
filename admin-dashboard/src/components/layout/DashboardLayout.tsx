import { useState } from "react";
import { Outlet, useNavigate } from "react-router-dom";
import { Sidebar } from "./Sidebar";
import { useAuthStore } from "@/store/auth";
import { Bell, ChevronDown, Menu } from "lucide-react";

export function DashboardLayout() {
  const { user, logout } = useAuthStore();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-surface">
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />
      {/* Top bar */}
      <header className="fixed top-0 left-0 right-0 lg:right-64 h-16 bg-white border-b border-border flex items-center justify-between px-4 lg:px-8 z-30">
        <div className="flex items-center gap-3">
          <button className="lg:hidden p-2 rounded-xl hover:bg-surface transition-colors" onClick={() => setSidebarOpen(true)}>
            <Menu className="h-5 w-5 text-text-secondary" />
          </button>
          <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center">
            <span className="text-primary font-bold text-sm">
              {user?.name?.charAt(0) || "م"}
            </span>
          </div>
          <span className="text-sm font-medium text-text hidden sm:inline">{user?.name || "مدير المنصة"}</span>
          <ChevronDown className="h-4 w-4 text-text-secondary hidden sm:inline" />
        </div>
        <div className="flex items-center gap-4">
          <button className="relative p-2 rounded-xl hover:bg-surface transition-colors" onClick={() => navigate("/notifications") }>
            <Bell className="h-5 w-5 text-text-secondary" />
            <span className="absolute -top-0.5 -right-0.5 w-4 h-4 bg-danger text-white text-[10px] font-bold rounded-full flex items-center justify-center">3</span>
          </button>
        </div>
      </header>
      <main className="lg:mr-64 pt-16 p-4 lg:p-8">
        <Outlet />
      </main>
    </div>
  );
}
