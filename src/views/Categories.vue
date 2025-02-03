<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
} from "@heroicons/vue/24/outline";

import Button from "../components/ui/Button.vue";
import Input from "../components/ui/Input.vue";
import Select from "../components/ui/Select.vue";
import Modal from "../components/ui/Modal.vue";
import Alert from "../components/ui/Alert.vue";
import IconPicker from "../components/ui/IconPicker.vue";

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
  icon: "Home",
  color: "#3B82F6",
  amount: "",
  recurringInterval: "",
});

function formatAmount() {
  formData.value.amount = formData.value.amount.replace('.', ',');
}

// Create color picker
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
      amount: "",
      recurringInterval: "",
    };
    formData.value = {
      title: "",
      icon: "Home",
      color: "#3B82F6",
      amount: "",
      recurringInterval: "",
    };
  }
  showModal.value = true;
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

    showModal.value = false;
    await fetchCategories();
  } catch (e) {
    console.error("Error saving category:", e);
    error.value = "Error saving category. Please try again later.";
  }
}

async function checkCategoryUsage(id: string) {
  try {
    const { count: paymentsCount, error: paymentsError } = await supabase
      .from("payments")
      .select("*", { count: "exact", head: true })
      .eq("category_id", id);

    if (paymentsError) throw paymentsError;

    const { count: budgetsCount, error: budgetsError } = await supabase
      .from("budgets")
      .select("*", { count: "exact", head: true })
      .eq("category_id", id);

    if (budgetsError) throw budgetsError;

    return { paymentsCount, budgetsCount };
  } catch (e) {
    console.error("Error checking category usage:", e);
    throw new Error("Unable to verify category usage");
  }
}

async function openDeleteModal(category: Category) {
  try {
    deletingCategory.value = category;
    deleteError.value = "";

    const { paymentsCount, budgetsCount } = await checkCategoryUsage(
      category.id
    );
    if ((paymentsCount ?? 0) > 0 || (budgetsCount ?? 0) > 0) {
      deleteError.value = `This category cannot be deleted because it has ${paymentsCount} payments and ${budgetsCount} budgets associated with it`;
    }

    showDeleteModal.value = true;
  } catch (e) {
    console.error("Error checking category usage:", e);
    error.value = "Unable to verify if the category can be deleted";
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
    error.value = "Unable to delete category. Please try again later.";
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
        <p class="mt-2 text-sm text-gray-700">
          Configure your categories for payments and budgets
        </p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <Button @click="openModal()" variant="primary">
          <template #icon-left>
            <PlusIcon class="h-5 w-5 inline-block mr-1" />
          </template>
          Categoria
        </Button>
      </div>
    </div>

    <Alert v-if="error" variant="error" class="mt-4">
      {{ error }}
    </Alert>

    <Alert v-if="success" variant="success" class="mt-4">
      {{ success }}
    </Alert>

    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading categories...</div>
    </div>

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
          <component
            :is="category.icon + 'Icon'"
            class="h-6 w-6"
            :style="{ color: category.color }"
          />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900">{{ category.title }}</p>
        </div>
        <div class="flex-shrink-0 space-x-2">
          <Button
            @click="openModal(category)"
            variant="secondary"
            size="sm"
            class="mr-2"
          >
            <PencilSquareIcon class="h-5 w-5" />
          </Button>
          <Button @click="openDeleteModal(category)" variant="abort" size="sm">
            <TrashIcon class="h-5 w-5" />
          </Button>
        </div>
      </div>
    </div>

    <!-- Edit Modal -->
    <Modal
      v-model="showModal"
      :title="editingCategory ? 'Edit Category' : 'Add Category'"
    >
      <div class="space-y-4">
        <form @submit.prevent="handleSubmit" @input="formatAmount">
          <Input v-model="formData.title" label="Name" required />

          <div>
            <label class="block text-sm font-medium text-gray-700">Icon</label>
            <div class="mt-2">
              <IconPicker v-model="formData.icon" />
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700">Color</label>
            <div class="mt-2 grid grid-cols-6 gap-2">
              <Button
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
          <div>
            <label class="block text-sm font-medium text-gray-700">Recurring Interval</label>
            <Select v-model="formData.recurringInterval" placeholder="Select interval">
              <option value="daily">Daily</option>
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
              <option value="yearly">Yearly</option>
            </Select>
          </div>
        </form>
      </div>
      <template #footer>
        <Button @click="handleSubmit" variant="primary" class="ml-3">
          {{ editingCategory ? "Update" : "Create" }} Category
        </Button>
        <Button @click="showModal = false" variant="secondary"> Cancel </Button>
      </template>
    </Modal>

    <!-- Delete Modal -->
    <Modal
      v-model="showDeleteModal"
      title="Delete Category"
      icon="ExclamationTriangleIcon"
      iconClass="text-red-600"
      iconBackgroundClass="bg-red-100"
    >
      <p class="text-sm text-gray-500">
        Are you sure you want to delete the category "{{
          deletingCategory?.title
        }}"? This action cannot be undone.
      </p>
      <div v-if="deleteError" class="mt-2 text-sm text-red-600">
        {{ deleteError }}
      </div>

      <template #footer>
        <Button
          @click="handleDelete"
          variant="abort"
          :disabled="!!deleteError"
          class="ml-3"
        >
          Delete
        </Button>
        <Button @click="showDeleteModal = false" variant="secondary">
          Cancel
        </Button>
      </template>
    </Modal>
  </div>
</template>
