import { Navigate } from "react-router-dom";
import { useAuthStore } from "@/store/auth";
import { useEffect } from "react";

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { isAuthenticated, user, setUser } = useAuthStore();

  // Auto-login with demo admin account for development
  useEffect(() => {
    if (!isAuthenticated) {
      const demoAdmin = {
        id: "admin-demo-001",
        email: "admin@wowgift.app",
        name: "مدير النظام",
        role: "admin" as const,
        avatar: "",
      };
      setUser(demoAdmin);
    }
  }, [isAuthenticated, setUser]);

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (user?.role !== "admin") {
    return (
      <div className="min-h-screen flex items-center justify-center bg-surface">
        <div className="text-center p-8 bg-white rounded-[var(--radius-lg)] shadow-sm border border-border max-w-md">
          <div className="w-16 h-16 rounded-full bg-danger/10 flex items-center justify-center mx-auto mb-4">
            <span className="text-danger text-2xl font-bold">!</span>
          </div>
          <h2 className="text-xl font-bold text-text mb-2">غير مصرح</h2>
          <p className="text-text-secondary mb-4">
            هذه اللوحة مخصصة لمديري المنصة فقط. ليس لديك صلاحية الوصول.
          </p>
          <button
            onClick={() => {
              localStorage.removeItem("admin_token");
              localStorage.removeItem("admin_user");
              window.location.href = "/login";
            }}
            className="px-6 py-2 bg-primary text-white rounded-xl font-medium hover:bg-primary-dark transition-colors"
          >
            تسجيل الدخول بحساب آخر
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
