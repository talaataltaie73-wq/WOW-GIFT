import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import api from "@/lib/api";
import {
  mockUsers,
  mockStores,
  mockProducts,
  mockOrders,
  mockCategories,
  mockCoupons,
  mockBanners,
  mockNotifications,
  mockDashboardStats,
  mockReportData,
} from "@/lib/mock-data";
import type { OrderStatus, Category, Coupon, Banner, Product } from "@/types";

async function fetchWithFallback<T>(url: string, fallback: T): Promise<T> {
  try {
    const res = await api.get(url);
    const data = res.data;

    if (data == null) {
      return fallback;
    }

    if (Array.isArray(data) && data.length === 0) {
      return fallback;
    }

    return data;
  } catch {
    return fallback;
  }
}

export function useDashboardStats() {
  return useQuery({
    queryKey: ["admin-dashboard-stats"],
    queryFn: () => {
      const stats = { ...mockDashboardStats, pending_approvals: mockStores.filter((s) => s.status === "pending") };
      return fetchWithFallback("/admin/dashboard", stats);
    },
  });
}

export function useUsers() {
  return useQuery({
    queryKey: ["admin-users"],
    queryFn: () => fetchWithFallback("/users/", mockUsers),
  });
}

export function useStores() {
  return useQuery({
    queryKey: ["admin-stores"],
    queryFn: () => fetchWithFallback("/stores/", mockStores),
  });
}

export function useProducts() {
  return useQuery({
    queryKey: ["admin-products"],
    queryFn: () => fetchWithFallback("/products/", mockProducts),
  });
}

export function useOrders() {
  return useQuery({
    queryKey: ["admin-orders"],
    queryFn: () => fetchWithFallback("/orders/", mockOrders),
  });
}

export function useCategories() {
  return useQuery({
    queryKey: ["admin-categories"],
    queryFn: () => fetchWithFallback("/categories/", mockCategories),
  });
}

export function useUpdateProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<Product> }) => {
      try {
        const res = await api.put(`/products/${id}`, data);
        return res.data;
      } catch {
        return { id, ...data } as Product;
      }
    },
    onSuccess: (updatedProduct) => {
      qc.setQueryData<Product[]>(["admin-products"], (old) => {
        if (Array.isArray(old)) {
          return old.map((product) => (product.id === updatedProduct.id ? { ...product, ...updatedProduct } : product));
        }
        if (!old) {
          return [updatedProduct];
        }
        if (typeof old === "object" && (old as any).id) {
          const o = old as any;
          return o.id === updatedProduct.id ? [{ ...o, ...updatedProduct }] : [o, updatedProduct];
        }
        return [updatedProduct];
      });
    },
  });
}

export function useCoupons() {
  return useQuery({
    queryKey: ["admin-coupons"],
    queryFn: () => fetchWithFallback("/coupons/", mockCoupons),
  });
}

export function useBanners() {
  return useQuery({
    queryKey: ["admin-banners"],
    queryFn: () => fetchWithFallback("/banners/", mockBanners),
  });
}

export function useNotifications() {
  return useQuery({
    queryKey: ["admin-notifications"],
    queryFn: () => fetchWithFallback("/notifications/", mockNotifications),
  });
}

export function useReportData() {
  return useQuery({
    queryKey: ["admin-reports"],
    queryFn: () => fetchWithFallback("/admin/reports", mockReportData),
  });
}

export function useApproveStore() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        const res = await api.patch(`/stores/${id}/approve`);
        return res.data;
      } catch {
        return { id, status: "active" };
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["admin-stores"] });
      qc.invalidateQueries({ queryKey: ["admin-dashboard-stats"] });
    },
  });
}

export function useRejectStore() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        const res = await api.patch(`/stores/${id}/reject`);
        return res.data;
      } catch {
        return { id, status: "rejected" };
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["admin-stores"] });
      qc.invalidateQueries({ queryKey: ["admin-dashboard-stats"] });
    },
  });
}

export function useUpdateOrderStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: OrderStatus }) => {
      try {
        const res = await api.patch(`/orders/${id}/status`, { status });
        return res.data;
      } catch {
        return { id, status };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-orders"] }),
  });
}

export function useToggleUserStatus() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, is_active }: { id: string; is_active: boolean }) => {
      try {
        const res = await api.patch(`/users/${id}`, { is_active });
        return res.data;
      } catch {
        return { id, is_active };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-users"] }),
  });
}

export function useCreateCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (data: Partial<Category>) => {
      try {
        const res = await api.post("/categories/", data);
        return res.data;
      } catch {
        return { ...data, id: "c" + Date.now() };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-categories"] }),
  });
}

export function useUpdateCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<Category> }) => {
      try {
        const res = await api.put(`/categories/${id}`, data);
        return res.data;
      } catch {
        return { ...data, id };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-categories"] }),
  });
}

export function useDeleteCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        await api.delete(`/categories/${id}`);
      } catch {
        // mock
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-categories"] }),
  });
}

export function useCreateCoupon() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (data: Partial<Coupon>) => {
      try {
        const res = await api.post("/coupons/", data);
        return res.data;
      } catch {
        return { ...data, id: "cp" + Date.now(), used_count: 0, created_at: new Date().toISOString() };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-coupons"] }),
  });
}

export function useUpdateCoupon() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<Coupon> }) => {
      try {
        const res = await api.put(`/coupons/${id}`, data);
        return res.data;
      } catch {
        return { ...data, id };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-coupons"] }),
  });
}

export function useCreateBanner() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (data: Partial<Banner>) => {
      try {
        const res = await api.post("/banners/", data);
        return res.data;
      } catch {
        return { ...data, id: "b" + Date.now(), created_at: new Date().toISOString() };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-banners"] }),
  });
}

export function useUpdateBanner() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Partial<Banner> }) => {
      try {
        const res = await api.put(`/banners/${id}`, data);
        return res.data;
      } catch {
        return { ...data, id };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-banners"] }),
  });
}

export function useDeleteBanner() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      try {
        await api.delete(`/banners/${id}`);
      } catch {
        // mock
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-banners"] }),
  });
}

export function useSendNotification() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (data: { title: string; message: string; target: string }) => {
      try {
        const res = await api.post("/notifications/send", data);
        return res.data;
      } catch {
        return { ...data, id: "n" + Date.now(), created_at: new Date().toISOString() };
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-notifications"] }),
  });
}
