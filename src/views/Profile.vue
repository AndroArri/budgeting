<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";
import { useAuthStore } from "../stores/auth";
import { XMarkIcon } from "@heroicons/vue/24/outline";
import Input from "../components/ui/Input.vue";


interface UserProfile {
  id: string;
  first_name: string | null;
  last_name: string | null;
  created_at: string | null;
  updated_at: string | null;
}

interface Category {
  id: string;
  title: string;
  icon: string;
  color: string;
}

interface CSVRow {
  title: string;
  amount: number;
  isIncome: boolean;
  category: string;
}

interface PendingTransaction {
  title: string;
  amount: number;
  isIncome: boolean;
  categoryName: string;
}

const authStore = useAuthStore();
const profile = ref<UserProfile | null>(null);
const loading = ref(true);
const saving = ref(false);
const error = ref("");
const success = ref("");
const categories = ref<Category[]>([]);

const formData = ref({
  first_name: "",
  last_name: "",
});

// CSV Import
const showCategoryModal = ref(false);
const pendingTransaction = ref<PendingTransaction | null>(null);
const newCategoryData = ref({
  title: "",
  icon: "🏠",
  color: "#3B82F6",
});

// Icon and color options
const icons = [
  "🏠",
  "🚗",
  "🍔",
  "🎮",
  "🏥",
  "🎓",
  "💼",
  "🛒",
  "✈️",
  "🎭",
  "💪",
  "📱",
];

const colors = [
  "#3B82F6",
  "#EF4444",
  "#10B981",
  "#F59E0B",
  "#8B5CF6",
  "#EC4899",
  "#6366F1",
  "#14B8A6",
  "#F97316",
  "#06B6D4",
  "#84CC16",
  "#9333EA",
];

async function fetchProfile() {
  try {
    loading.value = true;
    error.value = "";

    const { data, error: err } = await supabase
      .from("user_profiles")
      .select("*")
      .eq("id", authStore.user?.id)
      .single();

    if (err) throw err;

    profile.value = data;
    formData.value = {
      first_name: data?.first_name || "",
      last_name: data?.last_name || "",
    };
  } catch (e) {
    error.value = "Error loading profile";
    console.error("Error:", e);
  } finally {
    loading.value = false;
  }
}

async function updateProfile() {
  try {
    saving.value = true;
    error.value = "";
    success.value = "";

    const { error: err } = await supabase.from("user_profiles").upsert({
      id: authStore.user?.id,
      first_name: formData.value.first_name,
      last_name: formData.value.last_name,
    });

    if (err) throw err;

    success.value = "Profile updated successfully";
    await fetchProfile();
  } catch (e) {
    error.value = "Error updating profile";
    console.error("Error:", e);
  } finally {
    saving.value = false;
  }
}

async function fetchCategories() {
  try {
    const { data, error: err } = await supabase.from("categories").select("*");

    if (err) throw err;
    categories.value = data || [];
  } catch (e) {
    console.error("Error fetching categories:", e);
    error.value = "Error loading categories";
  }
}

async function handleFileUpload(event: Event) {
  const input = event.target as HTMLInputElement;
  if (!input.files?.length) return;

  const file = input.files[0];
  const reader = new FileReader();

  reader.onload = async (e) => {
    try {
      const text = e.target?.result as string;
      const rows = text.split("\n");
      const headers = rows[0].split(",");

      // Process each row
      for (let i = 1; i < rows.length; i++) {
        const row = rows[i].split(",");
        if (row.length !== headers.length) continue;

        const transaction: CSVRow = {
          title: row[0].trim(),
          amount: parseFloat(row[1]),
          isIncome: row[2].toLowerCase() === "true",
          category: row[3].trim(),
        };

        // Find category
        const category = categories.value.find(
          (c) => c.title.toLowerCase() === transaction.category.toLowerCase()
        );

        if (category) {
          // Save directly if category exists
          await saveTransaction(transaction, category.id);
        } else {
          // Show modal for category creation
          pendingTransaction.value = {
            title: transaction.title,
            amount: transaction.amount,
            isIncome: transaction.isIncome,
            categoryName: transaction.category,
          };
          newCategoryData.value.title = transaction.category;
          showCategoryModal.value = true;
          break; // Process one missing category at a time
        }
      }

      success.value = "CSV import completed successfully";
      // Reset file input
      input.value = "";
    } catch (e) {
      console.error("Error processing CSV:", e);
      error.value = "Error processing CSV file";
    }
  };

  reader.readAsText(file);
}

async function saveTransaction(transaction: CSVRow, categoryId: string) {
  const user = await supabase.auth.getUser();
  const userId = user.data.user?.id;

  if (!userId) throw new Error("User not authenticated");

  if (transaction.isIncome) {
    await supabase.from("incomes").insert({
      title: transaction.title,
      price: transaction.amount,
      is_personal: false,
      user_id: userId,
    });
  } else {
    await supabase.from("payments").insert({
      title: transaction.title,
      price: transaction.amount,
      category_id: categoryId,
      date: new Date().toISOString().split("T")[0],
      is_personal: false,
      user_id: userId,
    });
  }
}

async function handleCreateCategory() {
  if (!pendingTransaction.value) return;

  try {
    const user = await supabase.auth.getUser();
    const userId = user.data.user?.id;
    if (!userId) throw new Error("User not authenticated");

    // Create new category
    const { data: categoryData, error: categoryError } = await supabase
      .from("categories")
      .insert({
        title: newCategoryData.value.title,
        icon: newCategoryData.value.icon,
        color: newCategoryData.value.color,
        user_id: userId,
      })
      .select()
      .single();

    if (categoryError) throw categoryError;

    // Save the transaction with the new category
    await saveTransaction(
      {
        title: pendingTransaction.value.title,
        amount: pendingTransaction.value.amount,
        isIncome: pendingTransaction.value.isIncome,
        category: pendingTransaction.value.categoryName,
      },
      categoryData.id
    );

    // Refresh categories and close modal
    await fetchCategories();
    showCategoryModal.value = false;
    pendingTransaction.value = null;

    // Continue processing the CSV if there are more rows
    success.value = "Category created and transaction saved";
  } catch (e) {
    console.error("Error creating category:", e);
    error.value = "Error creating category";
  }
}

onMounted(() => {
  fetchProfile();
  fetchCategories();
});
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Profile</h1>
        <p class="mt-2 text-sm text-gray-700">
          Manage your profile information
        </p>
      </div>
    </div>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Success Alert -->
    <div v-if="success" class="mt-4 rounded-md bg-green-50 p-4">
      <div class="text-sm text-green-700">{{ success }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading profile...</div>
    </div>

    <!-- Profile Form -->
    <div v-else class="mt-6">
      <div class="bg-white shadow sm:rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <form @submit.prevent="updateProfile" class="space-y-6">
            <div>
              <label
                for="email"
                class="block text-sm font-medium text-gray-700"
              >
                Email address
              </label>
              <div class="mt-1">
                <Input
                  type="email"
                  :modelValue="authStore.user?.email"
                  disabled
                />
              </div>
            </div>

            <div>
              <label
                for="first_name"
                class="block text-sm font-medium text-gray-700"
              >
                First name
              </label>
              <div class="mt-1">
                <Input
                  id="first_name"
                  v-model="formData.first_name"
                  type="text"
                />
              </div>
            </div>

            <div>
              <label
                for="last_name"
                class="block text-sm font-medium text-gray-700"
              >
                Last name
              </label>
              <div class="mt-1">
                <Input
                  id="last_name"
                  v-model="formData.last_name"
                  type="text"
                />
              </div>
            </div>

            <div class="flex justify-end space-x-3">
              <div class="relative">
                <input
                  type="file"
                  accept=".csv"
                  @change="handleFileUpload"
                  class="hidden"
                  id="csv-upload"
                />
                <label
                  for="csv-upload"
                  class="cursor-pointer inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Import CSV
                </label>
              </div>
              <button
                type="submit"
                :disabled="saving"
                class="inline-flex justify-center rounded-md border border-transparent bg-indigo-600 py-2 px-4 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 disabled:opacity-50"
              >
                {{ saving ? "Saving..." : "Save" }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Category Creation Modal -->
    <div
      v-if="showCategoryModal"
      class="relative z-50"
      aria-labelledby="modal-title"
      role="dialog"
      aria-modal="true"
    >
      <div
        class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      ></div>

      <div class="fixed inset-0 z-50 overflow-y-auto">
        <div
          class="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0"
        >
          <div
            class="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
          >
            <div class="absolute right-0 top-0 pr-4 pt-4">
              <button
                type="button"
                @click="showCategoryModal = false"
                class="rounded-md bg-white text-gray-400 hover:text-gray-500"
              >
                <XMarkIcon class="h-6 w-6" />
              </button>
            </div>

            <div class="sm:flex sm:items-start">
              <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left w-full">
                <h3 class="text-base font-semibold leading-6 text-gray-900">
                  Create Category for Transaction
                </h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500">
                    Transaction: {{ pendingTransaction?.title }} ({{
                      pendingTransaction?.amount
                    }}
                    - {{ pendingTransaction?.isIncome ? "Income" : "Payment" }})
                  </p>
                </div>

                <div class="mt-4 space-y-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700"
                      >Category Name</label
                    >
                    <input
                      type="text"
                      v-model="newCategoryData.title"
                      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700"
                      >Icon</label
                    >
                    <div class="mt-2 grid grid-cols-6 gap-2">
                      <button
                        v-for="icon in icons"
                        :key="icon"
                        type="button"
                        @click="newCategoryData.icon = icon"
                        :class="[
                          'p-2 rounded-md text-xl',
                          newCategoryData.icon === icon
                            ? 'bg-indigo-100 ring-2 ring-indigo-500'
                            : 'hover:bg-gray-100',
                        ]"
                      >
                        {{ icon }}
                      </button>
                    </div>
                  </div>

                  <div>
                    <label class="block text-sm font-medium text-gray-700"
                      >Color</label
                    >
                    <div class="mt-2 grid grid-cols-6 gap-2">
                      <button
                        v-for="color in colors"
                        :key="color"
                        type="button"
                        @click="newCategoryData.color = color"
                        :class="[
                          'w-8 h-8 rounded-full',
                          newCategoryData.color === color
                            ? 'ring-2 ring-offset-2 ring-indigo-500'
                            : '',
                        ]"
                        :style="{ backgroundColor: color }"
                      />
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
              <button
                type="button"
                @click="handleCreateCategory"
                class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 sm:ml-3 sm:w-auto"
              >
                Create Category
              </button>
              <button
                type="button"
                @click="showCategoryModal = false"
                class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
