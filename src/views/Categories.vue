<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";

interface Category {
  id: string;
  title: string;
  icon: string;
  color: string;
}

const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref("");
const success = ref("");

const showModal = ref(false);
const showDeleteModal = ref(false);
const editingCategory = ref<Category | null>(null);
const deletingCategory = ref<Category | null>(null);
const deleteError = ref("");
const formData = ref({
  title: "",
  icon: "🏠",
  color: "#3B82F6",
});

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
  "#3B82F6", // Blue
  "#EF4444", // Red
  "#10B981", // Green
  "#F59E0B", // Yellow
  "#8B5CF6", // Purple
  "#EC4899", // Pink
  "#6366F1", // Indigo
  "#14B8A6", // Teal
  "#F97316", // Orange
  "#06B6D4", // Cyan
  "#84CC16", // Lime
  "#9333EA", // Violet
];

async function fetchCategories() {
  try {
    loading.value = true;
    error.value = "";

    const { data, error: err } = await supabase
      .from("categories")
      .select("*")
      .order("created_at", { ascending: false });

    if (err) throw err;
    categories.value = data || [];
  } catch (e) {
    console.error("Error loading categories:", e);
    error.value =
      "Unable to load categories. Please check your connection and try again.";
  } finally {
    loading.value = false;
  }
}

function openModal(category: Category | null = null) {
  if (category) {
    editingCategory.value = category;
    formData.value = {
      title: category.title,
      icon: category.icon,
      color: category.color,
    };
  } else {
    editingCategory.value = null;
    formData.value = {
      title: "",
      icon: "🏠",
      color: "#3B82F6",
    };
  }
  showModal.value = true;
}

function closeModal() {
  showModal.value = false;
  editingCategory.value = null;
  formData.value = {
    title: "",
    icon: "🏠",
    color: "#3B82F6",
  };
}

async function handleSubmit() {
  try {
    error.value = "";
    success.value = "";

    if (editingCategory.value) {
      const { error: err } = await supabase
        .from("categories")
        .update({
          title: formData.value.title,
          icon: formData.value.icon,
          color: formData.value.color,
        })
        .eq("id", editingCategory.value.id);

      if (err) throw err;
      success.value = "Category updated successfully";
    } else {
      const user = await supabase.auth.getUser();
      const user_id = user.data.user?.id;
      
      if (!user_id) throw new Error("User not found");

      const { error: err } = await supabase.from("categories").insert({
        title: formData.value.title,
        icon: formData.value.icon,
        color: formData.value.color,
        user_id,
      });

      if (err) throw err;
      success.value = "Category created successfully";
    }

    closeModal();
    await fetchCategories();
  } catch (e) {
    console.error("Error saving category:", e);
    error.value = "Unable to save category. Please try again.";
  }
}

async function checkCategoryUsage(id: string) {
  try {
    // Check payments
    const { count: paymentsCount, error: paymentsError } = await supabase
      .from("payments")
      .select("*", { count: "exact", head: true })
      .eq("category_id", id);

    if (paymentsError) throw paymentsError;

    // Check budgets
    const { count: budgetsCount, error: budgetsError } = await supabase
      .from("budgets")
      .select("*", { count: "exact", head: true })
      .eq("category_id", id);

    if (budgetsError) throw budgetsError;

    return { paymentsCount, budgetsCount };
  } catch (e) {
    console.error("Error checking category usage:", e);
    throw new Error("Unable to check if category can be deleted");
  }
}

async function openDeleteModal(category: Category) {
  try {
    deletingCategory.value = category;
    deleteError.value = "";

    const { paymentsCount, budgetsCount } = await checkCategoryUsage(
      category.id
    );

    if (
      !paymentsCount ||
      !budgetsCount ||
      paymentsCount > 0 ||
      budgetsCount > 0
    ) {
      deleteError.value = `This category cannot be deleted because it is being used in ${paymentsCount} payment(s) and ${budgetsCount} budget(s)`;
    }

    showDeleteModal.value = true;
  } catch (e) {
    console.error("Error checking category usage:", e);
    error.value = "Unable to check if category can be deleted";
  }
}

async function handleDelete() {
  if (!deletingCategory.value) return;

  try {
    const { error: err } = await supabase
      .from("categories")
      .delete()
      .eq("id", deletingCategory.value.id);

    if (err) throw err;

    success.value = "Category deleted successfully";
    showDeleteModal.value = false;
    deletingCategory.value = null;
    await fetchCategories();
  } catch (e) {
    console.error("Error deleting category:", e);
    error.value = "Unable to delete category. Please try again.";
  }
}

onMounted(() => {
  fetchCategories();
});
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Categories</h1>
        <p class="mt-2 text-sm text-gray-700">Manage your expense categories</p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <button
          type="button"
          @click="openModal()"
          class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-indigo-500"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-1" />
          Add Category
        </button>
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
      <div class="text-sm text-gray-500">Loading categories...</div>
    </div>

    <!-- Categories Grid -->
    <div
      v-else
      class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3"
    >
      <div
        v-for="category in categories"
        :key="category.id"
        class="relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm"
      >
        <div
          class="flex-shrink-0 rounded-full p-2"
          :style="{ backgroundColor: category.color + '20' }"
        >
          <span class="text-2xl">{{ category.icon }}</span>
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900">{{ category.title }}</p>
        </div>
        <div class="flex-shrink-0 space-x-2">
          <button
            @click.prevent="openModal(category)"
            class="text-gray-400 hover:text-indigo-600"
          >
            <PencilSquareIcon class="h-5 w-5" />
          </button>
          <button
            @click.prevent="openDeleteModal(category)"
            class="text-gray-400 hover:text-red-600"
          >
            <TrashIcon class="h-5 w-5" />
          </button>
        </div>
      </div>
    </div>

    <!-- Edit Modal -->
    <div
      v-if="showModal"
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
                @click="closeModal"
                class="rounded-md bg-white text-gray-400 hover:text-gray-500"
              >
                <XMarkIcon class="h-6 w-6" />
              </button>
            </div>

            <form @submit.prevent="handleSubmit">
              <div class="space-y-4">
                <div>
                  <label
                    for="title"
                    class="block text-sm font-medium text-gray-700"
                  >
                    Category Name
                  </label>
                  <input
                    type="text"
                    id="title"
                    v-model="formData.title"
                    required
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
                      @click="formData.icon = icon"
                      :class="[
                        'p-2 rounded-md text-xl',
                        formData.icon === icon
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
                      @click="formData.color = color"
                      :class="[
                        'w-8 h-8 rounded-full',
                        formData.color === color
                          ? 'ring-2 ring-offset-2 ring-indigo-500'
                          : '',
                      ]"
                      :style="{ backgroundColor: color }"
                    />
                  </div>
                </div>
              </div>

              <div class="mt-5 sm:mt-6 flex space-x-3">
                <button
                  type="button"
                  @click="closeModal"
                  class="inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  {{ editingCategory ? "Update" : "Create" }} Category
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Delete Modal -->
    <div
      v-if="showDeleteModal"
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
            <div class="sm:flex sm:items-start">
              <div
                class="mx-auto flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10"
              >
                <ExclamationTriangleIcon
                  class="h-6 w-6 text-red-600"
                  aria-hidden="true"
                />
              </div>
              <div class="mt-3 text-center sm:ml-4 sm:mt-0 sm:text-left">
                <h3 class="text-base font-semibold leading-6 text-gray-900">
                  Delete Category
                </h3>
                <div class="mt-2">
                  <p class="text-sm text-gray-500">
                    Are you sure you want to delete the category "{{
                      deletingCategory?.title
                    }}"? This action cannot be undone.
                  </p>
                  <div v-if="deleteError" class="mt-2 text-sm text-red-600">
                    {{ deleteError }}
                  </div>
                </div>
              </div>
            </div>
            <div class="mt-5 sm:mt-4 sm:flex sm:flex-row-reverse">
              <button
                type="button"
                :disabled="!!deleteError"
                @click="handleDelete"
                class="inline-flex w-full justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:ml-3 sm:w-auto disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Delete
              </button>
              <button
                type="button"
                @click="showDeleteModal = false"
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
