<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";
import { format } from "date-fns";
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  XMarkIcon,
} from "@heroicons/vue/24/outline";

interface Payment {
  id: string;
  title: string;
  price: number;
  date: string;
  category_id: string;
  is_personal: boolean;
}

interface Category {
  id: string;
  title: string;
  icon: string;
}

const payments = ref<Payment[]>([]);
const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref("");
const success = ref("");

const showModal = ref(false);
const editingPayment = ref<Payment | null>(null);
const formData = ref({
  title: "",
  price: 0,
  date: format(new Date(), "yyyy-MM-dd"),
  category_id: "",
  is_personal: false,
});

async function fetchPayments() {
  try {
    loading.value = true;
    error.value = "";

    const { data, error: err } = await supabase
      .from("payments")
      .select("*")
      .order("date", { ascending: false });

    if (err) throw err;
    payments.value = data.map((payment) => ({
      ...payment,
      is_personal: payment.is_personal ?? false,
    }));
  } catch (e) {
    error.value = "Error loading payments";
    console.error("Error:", e);
  } finally {
    loading.value = false;
  }
}

async function fetchCategories() {
  try {
    const { data, error: err } = await supabase
      .from("categories")
      .select("*")
      .order("title", { ascending: true });

    if (err) throw err;
    if (data.length === 0) {
      throw new Error("No categories found");
    }
    categories.value = data;
  } catch (e) {
    error.value = "Error loading categories";
    console.error("Error:", e);
  }
}

function openModal(payment: Payment | null = null) {
  if (payment) {
    editingPayment.value = payment;
    formData.value = {
      title: payment.title,
      price: payment.price,
      date: payment.date,
      category_id: payment.category_id,
      is_personal: payment.is_personal,
    };
  } else {
    editingPayment.value = null;
    formData.value = {
      title: "",
      price: 0,
      date: format(new Date(), "yyyy-MM-dd"),
      category_id: categories.value[0]?.id || "",
      is_personal: false,
    };
  }
  showModal.value = true;
}

async function handleSubmit() {
  try {
    error.value = "";
    success.value = "";

    if (editingPayment.value) {
      const { error: err } = await supabase
        .from("payments")
        .update({
          title: formData.value.title,
          price: formData.value.price,
          date: formData.value.date,
          category_id: formData.value.category_id,
          is_personal: formData.value.is_personal,
        })
        .eq("id", editingPayment.value.id);

      if (err) throw err;
      success.value = "Payment updated successfully";
    } else {
      const user = await supabase.auth.getUser();
      if (!user) throw new Error("User is not authenticated");
      if (!user.data.user) throw new Error("User data is not available");

      const { error: err } = await supabase.from("payments").insert({
        title: formData.value.title,
        price: formData.value.price,
        date: formData.value.date,
        category_id: formData.value.category_id,
        is_personal: formData.value.is_personal,
        user_id: user.data.user.id,
      });

      if (err) throw err;
      success.value = "Payment created successfully";
    }

    showModal.value = false;
    await fetchPayments();
  } catch (e) {
    error.value = "Error saving payment";
    console.error("Error:", e);
  }
}

async function deletePayment(id: string) {
  if (!confirm("Are you sure you want to delete this payment?")) return;

  try {
    error.value = "";
    const { error: err } = await supabase
      .from("payments")
      .delete()
      .eq("id", id);

    if (err) throw err;
    success.value = "Payment deleted successfully";
    await fetchPayments();
  } catch (e) {
    error.value = "Error deleting payment";
    console.error("Error:", e);
  }
}

onMounted(() => {
  fetchCategories();
  fetchPayments();
});
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Payments</h1>
        <p class="mt-2 text-sm text-gray-700">
          Manage your payments and expenses
        </p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <button
          type="button"
          @click="openModal()"
          class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-indigo-500"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-1" />
          Add Payment
        </button>
      </div>
    </div>

    <!-- Success Alert -->
    <div v-if="success" class="mt-4 rounded-md bg-green-50 p-4">
      <div class="text-sm text-green-700">{{ success }}</div>
    </div>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading payments...</div>
    </div>

    <!-- Payments Table -->
    <div v-else class="mt-8 flow-root">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <div
            class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg"
          >
            <table class="min-w-full divide-y divide-gray-300">
              <thead class="bg-gray-50">
                <tr>
                  <th
                    scope="col"
                    class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6"
                  >
                    Title
                  </th>
                  <th
                    scope="col"
                    class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                  >
                    Category
                  </th>
                  <th
                    scope="col"
                    class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
                  >
                    Date
                  </th>
                  <th
                    scope="col"
                    class="px-3 py-3.5 text-right text-sm font-semibold text-gray-900"
                  >
                    Amount
                  </th>
                  <th
                    scope="col"
                    class="px-3 py-3.5 text-center text-sm font-semibold text-gray-900"
                  >
                    Personal
                  </th>
                  <th scope="col" class="relative py-3.5 pl-3 pr-4 sm:pr-6">
                    <span class="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-gray-200 bg-white">
                <tr v-for="payment in payments" :key="payment.id">
                  <td
                    class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6"
                  >
                    {{ payment.title }}
                  </td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                    {{
                      categories.find((c) => c.id === payment.category_id)
                        ?.title
                    }}
                  </td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                    {{ format(new Date(payment.date), "dd MMM yyyy") }}
                  </td>
                  <td
                    class="whitespace-nowrap px-3 py-4 text-sm text-gray-900 text-right"
                  >
                    ${{ payment.price.toFixed(2) }}
                  </td>
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-center">
                    <span
                      :class="[
                        payment.is_personal
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-800',
                        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
                      ]"
                    >
                      {{ payment.is_personal ? "Yes" : "No" }}
                    </span>
                  </td>
                  <td
                    class="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6"
                  >
                    <button
                      @click="openModal(payment)"
                      class="text-indigo-600 hover:text-indigo-900 mr-2"
                    >
                      <PencilSquareIcon class="h-5 w-5" />
                    </button>
                    <button
                      @click="deletePayment(payment.id)"
                      class="text-red-600 hover:text-red-900"
                    >
                      <TrashIcon class="h-5 w-5" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal -->
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
                @click="showModal = false"
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
                    Title
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
                  <label
                    for="category"
                    class="block text-sm font-medium text-gray-700"
                  >
                    Category
                  </label>
                  <select
                    id="category"
                    v-model="formData.category_id"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  >
                    <option
                      v-for="category in categories"
                      :key="category.id"
                      :value="category.id"
                    >
                      {{ category.icon }} {{ category.title }}
                    </option>
                  </select>
                </div>

                <div>
                  <label
                    for="price"
                    class="block text-sm font-medium text-gray-700"
                  >
                    Amount
                  </label>
                  <div class="relative mt-1 rounded-md shadow-sm">
                    <div
                      class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
                    >
                      <span class="text-gray-500 sm:text-sm">€</span>
                    </div>
                    <input
                      type="number"
                      id="price"
                      v-model="formData.price"
                      required
                      min="0"
                      step="0.01"
                      class="block w-full rounded-md border-gray-300 pl-7 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>
                </div>

                <div>
                  <label
                    for="date"
                    class="block text-sm font-medium text-gray-700"
                  >
                    Date
                  </label>
                  <input
                    type="date"
                    id="date"
                    v-model="formData.date"
                    required
                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                  />
                </div>

                <div class="relative flex items-start">
                  <div class="flex h-6 items-center">
                    <input
                      id="is_personal"
                      v-model="formData.is_personal"
                      type="checkbox"
                      class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                    />
                  </div>
                  <div class="ml-3 text-sm leading-6">
                    <label for="is_personal" class="font-medium text-gray-900"
                      >Personal expense</label
                    >
                    <p class="text-gray-500">
                      Mark this payment as a personal expense
                    </p>
                  </div>
                </div>
              </div>

              <div class="mt-5 sm:mt-6">
                <button
                  type="submit"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  {{ editingPayment ? "Update" : "Create" }} Payment
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
