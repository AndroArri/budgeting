<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";
import { format } from "date-fns";
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  XMarkIcon,
  ArrowPathIcon,
} from "@heroicons/vue/24/outline";
import Input from "../components/ui/Input.vue";
import Select from "../components/ui/Select.vue";

interface Payment {
  id: string;
  title: string;
  price: number;
  date: string;
  category_id: string;
  is_personal: boolean;
  is_recurring: boolean;
  recurring_end_date: string | null;
  recurring_interval: "weekly" | "monthly" | "yearly" | null;
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
  is_recurring: false,
  recurring_end_date: "",
  recurring_interval: "" as "weekly" | "monthly" | "yearly" | "",
});

const recurringIntervals = [
  { value: "weekly", label: "Weekly" },
  { value: "monthly", label: "Monthly" },
  { value: "yearly", label: "Yearly" },
];

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
      is_recurring: payment.is_recurring ?? false,
      recurring_interval:
        (payment.recurring_interval as
          | "weekly"
          | "monthly"
          | "yearly"
          | null) ?? null,
    }));
  } catch (e) {
    error.value = "Errore nel caricamento dei pagamenti";
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
      is_recurring: payment.is_recurring,
      recurring_end_date: payment.recurring_end_date || "",
      recurring_interval: payment.recurring_interval || "",
    };
  } else {
    editingPayment.value = null;
    formData.value = {
      title: "",
      price: 0,
      date: format(new Date(), "yyyy-MM-dd"),
      category_id: categories.value[0]?.id || "",
      is_personal: false,
      is_recurring: false,
      recurring_end_date: "",
      recurring_interval: "",
    };
  }
  showModal.value = true;
}

async function handleSubmit() {
  try {
    error.value = "";
    success.value = "";

    // Validate recurring payment data
    if (formData.value.is_recurring && !formData.value.recurring_interval) {
      error.value = "Please select a recurring interval";
      return;
    }

    const paymentData = {
      title: formData.value.title,
      price: formData.value.price,
      date: formData.value.date,
      category_id: formData.value.category_id,
      is_personal: formData.value.is_personal,
      is_recurring: formData.value.is_recurring,
      recurring_end_date: formData.value.is_recurring
        ? formData.value.recurring_end_date || null
        : null,
      recurring_interval: formData.value.is_recurring
        ? formData.value.recurring_interval
        : null,
    };

    if (editingPayment.value) {
      const { error: err } = await supabase
        .from("payments")
        .update(paymentData)
        .eq("id", editingPayment.value.id);

      if (err) throw err;
      success.value = "Pagamento aggiornato con successo";
    } else {
      const user = await supabase.auth.getUser();
      if (!user) throw new Error("User is not authenticated");
      if (!user.data.user) throw new Error("User data is not available");

      const { error: err } = await supabase.from("payments").insert({
        ...paymentData,
        user_id: user.data.user.id,
      });

      if (err) throw err;
      success.value = "Pagamento creato con successo";
    }

    showModal.value = false;
    await fetchPayments();
  } catch (e) {
    error.value = "Errore nel salvataggio del pagamento";
    console.error("Error:", e);
  }
}

async function deletePayment(id: string) {
  if (!confirm("Sei sicuro di voler eliminare questo pagamento?")) return;

  try {
    error.value = "";
    const { error: err } = await supabase
      .from("payments")
      .delete()
      .eq("id", id);

    if (err) throw err;
    success.value = "Pagamento eliminato con successo";
    await fetchPayments();
  } catch (e) {
    error.value = "Errore nell'eliminazione del pagamento";
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
        <h1 class="text-2xl font-semibold text-gray-900">Pagamenti</h1>
        <p class="mt-2 text-sm text-gray-700">
          Gestisci i tuoi pagamenti e spese
        </p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <button
          type="button"
          @click="() => { showModal.value = true; openModal(); }"
          class="block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-indigo-500"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-1" />
          Aggiungi Pagamento
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
      <div class="text-sm text-gray-500">Caricamento pagamenti...</div>
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
                  <th
                    scope="col"
                    class="px-3 py-3.5 text-center text-sm font-semibold text-gray-900"
                  >
                    Recurring
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
                  <td class="whitespace-nowrap px-3 py-4 text-sm text-center">
                    <span
                      v-if="payment.is_recurring"
                      class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800"
                    >
                      <ArrowPathIcon class="h-3 w-3 mr-1" />
                      {{ payment.recurring_interval }}
                    </span>
                    <span v-else class="text-gray-500">-</span>
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
  </div>
  <!-- Modal -->
  <Modal
    v-model="showModal"
    :title="editingPayment ? 'Modifica Pagamento' : 'Aggiungi Pagamento'"
  >
    <form @submit.prevent="handleSubmit">
      <div class="space-y-4">
        <div>
          <label for="title" class="block text-sm font-medium text-gray-700">
            Titolo
          </label>
          <Input type="text" id="title" v-model="formData.title" required />
        </div>

        <div>
          <label for="category" class="block text-sm font-medium text-gray-700">
            Categoria
          </label>
          <Select id="category" v-model="formData.category_id" required>
            <option
              v-for="category in categories"
              :key="category.id"
              :value="category.id"
            >
              {{ category.icon }} {{ category.title }}
            </option>
          </Select>
        </div>

        <div>
          <label for="price" class="block text-sm font-medium text-gray-700">
            Importo
          </label>
          <div class="relative mt-1 rounded-md shadow-sm">
            <div
              class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
            >
              <span class="text-gray-500 sm:text-sm">€</span>
            </div>
            <Input
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
          <label for="date" class="block text-sm font-medium text-gray-700">
            Data di Inizio
          </label>
          <Input
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
              id="is_recurring"
              v-model="formData.is_recurring"
              type="checkbox"
              class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
            />
          </div>
          <div class="ml-3 text-sm leading-6">
            <label for="is_recurring" class="font-medium text-gray-900"
              >Recurring payment</label
            >
            <p class="text-gray-500">
              This payment will repeat at regular intervals
            </p>
          </div>
        </div>

        <div v-if="formData.is_recurring" class="space-y-4">
          <div>
            <label
              for="recurring_interval"
              class="block text-sm font-medium text-gray-700"
            >
              Recurring Interval
            </label>
            <Select
              id="recurring_interval"
              v-model="formData.recurring_interval"
              required
            >
              <option value="">Select interval</option>
              <option
                v-for="interval in recurringIntervals"
                :key="interval.value"
                :value="interval.value"
              >
                {{ interval.label }}
              </option>
            </Select>
          </div>

          <div>
            <label
              for="recurring_end_date"
              class="block text-sm font-medium text-gray-700"
            >
              End Date (Optional)
            </label>
            <input
              type="date"
              id="recurring_end_date"
              v-model="formData.recurring_end_date"
              :min="formData.date"
              class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
            />
          </div>
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
            <p class="text-gray-500">Mark this payment as a personal expense</p>
          </div>
        </div>
      </div>

      <div class="mt-5 sm:mt-6">
        <button
          type="submit"
          class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          {{ editingPayment ? "Aggiorna" : "Crea" }} Pagamento
        </button>
      </div>
    </form>
  </Modal>
</template>
