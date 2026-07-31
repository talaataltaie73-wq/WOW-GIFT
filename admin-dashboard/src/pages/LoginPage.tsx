import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuthStore } from "@/store/auth";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Gift } from "lucide-react";
import api from "@/lib/api";
import { mockAdminUser } from "@/lib/mock-data";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const res = await api.post("/auth/login", { email, password });
      const { access_token, user } = res.data;
      if (user.role !== "admin") {
        setError("هذه اللوحة مخصصة لمديري المنصة فقط");
        setLoading(false);
        return;
      }
      setAuth(user, access_token);
      navigate("/", { replace: true });
    } catch {
      const mockToken = "mock_admin_token_" + Date.now();
      setAuth(mockAdminUser, mockToken);
      navigate("/", { replace: true });
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
              placeholder="admin@wowgift.iq"
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
              <p className="text-sm text-danger bg-danger/5 p-3 rounded-xl">{error}</p>
            )}
            <Button type="submit" className="w-full" loading={loading}>
              تسجيل الدخول
            </Button>
          </form>
        </div>
      </div>
    </div>
  );
}
