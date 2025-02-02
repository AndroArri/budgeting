import { createRouter, createWebHistory } from "vue-router";
import { useAuthStore } from "../stores/auth";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/",
      component: () => import("../views/Dashboard.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/login",
      component: () => import("../views/Login.vue"),
      meta: { requiresAuth: false },
    },
    {
      path: "/register",
      component: () => import("../views/Register.vue"),
      meta: { requiresAuth: false },
    },
    {
      path: "/categories",
      component: () => import("../views/Categories.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/payments",
      component: () => import("../views/Payments.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/budgets",
      component: () => import("../views/Budgets.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/income",
      component: () => import("../views/Incomes.vue"),
      meta: { requiresAuth: true },
    },
    {
      path: "/profile",
      component: () => import("../views/Profile.vue"),
      meta: { requiresAuth: true },
    },
  ],
});

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore();

  if (to.meta.requiresAuth && !authStore.user) {
    next("/login");
  } else if (!to.meta.requiresAuth && authStore.user) {
    next("/");
  } else {
    next();
  }
});

export default router;
