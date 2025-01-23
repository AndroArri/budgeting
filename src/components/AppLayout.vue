<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { useAuthStore } from "../stores/auth";
import {
  HomeIcon,
  CreditCardIcon,
  TagIcon,
  ChartPieIcon,
  UserIcon,
  Bars3Icon,
  XMarkIcon,
} from "@heroicons/vue/24/outline";

const navigation = [
  { name: "Dashboard", href: "/", icon: HomeIcon },
  { name: "Payments", href: "/payments", icon: CreditCardIcon },
  { name: "Categories", href: "/categories", icon: TagIcon },
  { name: "Budgets", href: "/budgets", icon: ChartPieIcon },
  { name: "Profile", href: "/profile", icon: UserIcon },
];

const sidebarOpen = ref(false);
const router = useRouter();
const authStore = useAuthStore();

async function handleLogout() {
  await authStore.signOut();
  router.push("/login");
}
</script>

<template>
  <div>
    <!-- Mobile sidebar -->
    <div v-show="sidebarOpen" class="relative z-50 lg:hidden">
      <div class="fixed inset-0 bg-gray-900/80"></div>
      <div class="fixed inset-0 flex">
        <div class="relative mr-16 flex w-full max-w-xs flex-1">
          <div class="absolute left-full top-0 flex w-16 justify-center pt-5">
            <button
              type="button"
              @click="sidebarOpen = false"
              class="-m-2.5 p-2.5"
            >
              <XMarkIcon class="h-6 w-6 text-white" />
            </button>
          </div>
          <div
            class="flex grow flex-col gap-y-5 overflow-y-auto bg-white px-6 pb-2"
          >
            <div class="flex h-16 shrink-0 items-center">
              <span class="text-2xl font-bold text-indigo-600"
                >Family Finance</span
              >
            </div>
            <nav class="flex flex-1 flex-col">
              <ul role="list" class="flex flex-1 flex-col gap-y-7">
                <li>
                  <ul role="list" class="-mx-2 space-y-1">
                    <li v-for="item in navigation" :key="item.name">
                      <router-link
                        :to="item.href"
                        :class="[
                          $route.path === item.href
                            ? 'bg-gray-50 text-indigo-600'
                            : 'text-gray-700 hover:text-indigo-600 hover:bg-gray-50',
                          'group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold',
                        ]"
                      >
                        <component
                          :is="item.icon"
                          :class="[
                            $route.path === item.href
                              ? 'text-indigo-600'
                              : 'text-gray-400 group-hover:text-indigo-600',
                            'h-6 w-6 shrink-0',
                          ]"
                        />
                        {{ item.name }}
                      </router-link>
                    </li>
                  </ul>
                </li>
                <li class="mt-auto">
                  <button
                    @click="handleLogout"
                    class="text-gray-700 hover:text-indigo-600 hover:bg-gray-50 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold w-full"
                  >
                    Sign out
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Static sidebar for desktop -->
    <div
      class="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col"
    >
      <div
        class="flex grow flex-col gap-y-5 overflow-y-auto border-r border-gray-200 bg-white px-6"
      >
        <div class="flex h-16 shrink-0 items-center">
          <span class="text-2xl font-bold text-indigo-600">Family Finance</span>
        </div>
        <nav class="flex flex-1 flex-col">
          <ul role="list" class="flex flex-1 flex-col gap-y-7">
            <li>
              <ul role="list" class="-mx-2 space-y-1">
                <li v-for="item in navigation" :key="item.name">
                  <router-link
                    :to="item.href"
                    :class="[
                      $route.path === item.href
                        ? 'bg-gray-50 text-indigo-600'
                        : 'text-gray-700 hover:text-indigo-600 hover:bg-gray-50',
                      'group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold',
                    ]"
                  >
                    <component
                      :is="item.icon"
                      :class="[
                        $route.path === item.href
                          ? 'text-indigo-600'
                          : 'text-gray-400 group-hover:text-indigo-600',
                        'h-6 w-6 shrink-0',
                      ]"
                    />
                    {{ item.name }}
                  </router-link>
                </li>
              </ul>
            </li>
            <li class="mt-auto">
              <button
                @click="handleLogout"
                class="text-gray-700 hover:text-indigo-600 hover:bg-gray-50 group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold w-full"
              >
                Sign out
              </button>
            </li>
          </ul>
        </nav>
      </div>
    </div>

    <!-- Main content -->
    <div class="lg:pl-72">
      <div
        class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-gray-200 bg-white px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8"
      >
        <button
          type="button"
          @click="sidebarOpen = true"
          class="-m-2.5 p-2.5 text-gray-700 lg:hidden"
        >
          <Bars3Icon class="h-6 w-6" />
        </button>

        <div class="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
          <div class="flex items-center gap-x-4 lg:gap-x-6">
            <span class="text-sm font-semibold leading-6 text-gray-900">
              {{ authStore.user?.email }}
            </span>
          </div>
        </div>
      </div>

      <main class="py-10">
        <div class="px-4 sm:px-6 lg:px-8">
          <slot></slot>
        </div>
      </main>
    </div>
  </div>
</template>
