import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuthStore } from "@/store/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Gift } from "lucide-react";
import api from "@/lib/api";

export default function LoginPage() {
  const [email, setEmail] = useState("admin@wowgift.app");
  const [password, setPassword] = useState("admin123");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      // Call the real API endpoint
      const res = await api.post("/auth/admin/login", { 
        email: email.trim(), 
        password: password.trim() 
      });
      
      const { token, user } = res.data;
      
      if (user.role !== "admin") {
        setError("هذه اللوحة مخصصة لمديري المنصة فقط");
        setLoading(false);
        return;
      }
      
      // Update store (this also saves to localStorage)
      setAuth(user, token);
      
      // Redirect to dashboard
      navigate("/", { replace: true });
    } catch (err: any) {
      setError(
        err.response?.data?.detail || 
        "فشل تسجيل الدخول. تحقق من البيانات المدخلة."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-bl from-primary/5 via-surface to-accent/5">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-[var(--radius-lg)] shadow-lg border border-border p-8">
          <div className="text-center mb-8">
            <div className="w-16 h-16 rounded-2xl bg-primary flex items-center justify-center mx-auto mb-4">
              <Gift className="h-8 w-8 text-accent" />
            </div>
            <h1 className="text-2xl font-extrabold text-primary">Wow Gift</h1>
            <p className="text-text-secondary text-sm mt-1">لوحة إدارة المنصة</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-5">
            <Input
              label="البريد الإلكتروني"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="admin@wowgift.app"
              required
              dir="ltr"
            />
            <Input
              label="كلمة المرور"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
              dir="ltr"
            />
            {error && (
              <div className="text-sm text-danger bg-danger/5 p-3 rounded-xl border border-danger/10">
                {error}
              </div>
            )}
            
            <div className="p-3 bg-primary/5 rounded-xl border border-primary/10 text-xs text-text-secondary">
              <p className="font-medium text-primary mb-2">بيانات الاختبار:</p>
              <p>البريد: admin@wowgift.app</p>
              <p>الكلمة: admin123</p>
            </div>
            
            <Button type="submit" className="w-full" loading={loading}>
              تسجيل الدخول
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
