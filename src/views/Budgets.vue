<script setup lang="ts">
import { ref, onMounted } from "vue";
import { supabase } from "../supabase/client";
import {
  PlusIcon,
  PencilSquareIcon,
  TrashIcon,
  XMarkIcon,
} from "@heroicons/vue/24/outline";

import Button from "../components/ui/Button.vue";
import Input from "../components/ui/Input.vue";
import Modal from "../components/ui/Modal.vue";
import Alert from "../components/ui/Alert.vue";
import Select from "../components/ui/Select.vue";


interface Budget {
  id: string;
  title: string;
  amount: number;
  category_id: string;
  is_percentage: boolean;
}

interface Category {
  id: string;
  title: string;
  icon: string;
}

const budgets = ref<Budget[]>([]);
const categories = ref<Category[]>([]);
const loading = ref(true);
const error = ref("");
const success = ref("");
const disableAddBudget = ref(false);

const showModal = ref(false);
const editingBudget = ref<Budget | null>(null);
const formData = ref({
  title: "",
  amount: 0,
  category_id: "",
  is_percentage: false,
});

async function fetchBudgets() {
  try {
    loading.value = true;
    error.value = "";

    const { data, error: err } = await supabase
      .from("budgets")
      .select("*")
      .order("created_at", { ascending: false });

    if (err) throw err;
    if (data.length === 0) {
      // TODO Translate
      // TODO magari una modale?
      error.value = "Prima crea un budget";

      return;
    }
    budgets.value = data.map((budget: any) => ({
      ...budget,
      is_percentage: budget.is_percentage ?? false,
    }));
  } catch (e) {
    // TODO Translate
    error.value = "Errore durante il caricamento dei budget";
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
      // TODO Translate
      // TODO magari una modale?
      error.value = "Prima crea una categoria";
      disableAddBudget.value = true;
      return;
    }
    categories.value = data;
  } catch (e) {
    // TODO Translate
    error.value = "Errore durante il caricamento delle categorie";
    console.error("Error:", e);
  }
}

function openModal(budget: Budget | null = null) {
  if (budget) {
    editingBudget.value = budget;
    formData.value = {
      title: budget.title,
      amount: budget.amount,
      category_id: budget.category_id,
      is_percentage: budget.is_percentage,
    };
  } else {
    editingBudget.value = null;
    formData.value = {
      title: "",
      amount: 0,
      category_id: categories.value[0]?.id || "",
      is_percentage: false,
    };
  }
  showModal.value = true;
}

async function handleSubmit() {
  try {
    error.value = "";
    success.value = "";

    if (editingBudget.value) {
      const { error: err } = await supabase
        .from("budgets")
        .update({
          title: formData.value.title,
          amount: formData.value.amount,
          category_id: formData.value.category_id,
          is_percentage: formData.value.is_percentage,
        })
        .eq("id", editingBudget.value.id);

      if (err) throw err;
      // TODO Translate
      success.value = "Budget modificato con successo";
    } else {
      const user = await supabase.auth.getUser();
      const user_id = user.data.user?.id;
      // TODO Translate
      // TODO magari una modale?
      if (!user_id)
        throw new Error(
          "Errore durante la modifica. Prova a ricaricare la pagina"
        );

      const { error: err } = await supabase.from("budgets").insert({
        title: formData.value.title,
        amount: formData.value.amount,
        category_id: formData.value.category_id,
        is_percentage: formData.value.is_percentage,
        user_id,
      });

      if (err) throw err;
      success.value = "Budget creato con successo!";
    }

    showModal.value = false;
    await fetchBudgets();
  } catch (e) {
    error.value = "Errore durante il salvataggio del budget";
    console.error("Error:", e);
  }
}

async function deleteBudget(id: string) {
  // TODO modal
  if (!confirm("Sei sicuro di voler cancellare il budget?")) return;

  try {
    error.value = "";
    const { error: err } = await supabase.from("budgets").delete().eq("id", id);

    if (err) throw err;
    success.value = "Budget cancellato con successo!";
    await fetchBudgets();
  } catch (e) {
    error.value = "Errore durante la cancellazione";
    console.error("Error:", e);
  }
}

onMounted(() => {
  fetchCategories();
  fetchBudgets();
});
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Budgets</h1>
        <!-- TODO Translate -->
        <p class="mt-2 text-sm text-gray-700">Gestisci i tuoi budget</p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <Button
          type="button"
          @click="openModal()"
          variant="primary"
          :disabled="disableAddBudget"
        >
          <PlusIcon class="h-5 w-5 inline-block mr-1" />
          <!-- TODO Translate -->
          Budget
        </Button>
      </div>
    </div>

    <!-- Success Alert -->
    <div v-if="success" class="mt-4 rounded-md bg-green-50 p-4">
      <div class="text-sm text-green-700">{{ success }}</div>
    </div>
    <Alert :show="success !== ''">
      {{ success }}
    </Alert>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <!-- TODO Translate -->
      <div class="text-sm text-gray-500">Caricamento dei budget...</div>
    </div>

    <!-- Budgets Grid -->
    <div
      v-else
      class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3"
    >
      <div
        v-for="budget in budgets"
        :key="budget.id"
        class="relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm"
      >
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900">{{ budget.title }}</p>
          <p class="text-sm text-gray-500">
            {{ categories.find((c) => c.id === budget.category_id)?.title }}
          </p>
          <p class="mt-1 text-sm font-semibold text-indigo-600">
            {{
              budget.is_percentage
                ? `${budget.amount}%`
                : `€${budget.amount.toFixed(2)}`
            }}
          </p>
        </div>
        <div class="flex-shrink-0 space-x-2">
          <button
            @click.prevent="openModal(budget)"
            class="text-gray-400 hover:text-indigo-600"
          >
            <PencilSquareIcon class="h-5 w-5" />
          </button>
          <button
            @click.prevent="deleteBudget(budget.id)"
            class="text-gray-400 hover:text-red-600"
          >
            <TrashIcon class="h-5 w-5" />
          </button>
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
            class="relative transform rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
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
                    <!-- TODO Translate -->
                    Nome del budget
                  </label>
                  <Input
                    type="text"
                    id="title"
                    v-model="formData.title"
                    required
                  />
                </div>

                <div>
                  <label
                    for="category"
                    class="block text-sm font-medium text-gray-700"
                  >
                    <!-- TODO Translate -->
                    Categoria
                  </label>
                  <Select
                    id="category"
                    v-model="formData.category_id"
                    required
                  >
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
                  <label
                    for="amount"
                    class="block text-sm font-medium text-gray-700"
                  >
                    <!-- TODO Translate -->
                    Valore
                  </label>
                  <div class="relative mt-1 rounded-md shadow-sm">
                    <div
                      class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"
                    >
                      <span class="text-gray-500 sm:text-sm">{{
                        formData.is_percentage ? "%" : "€"
                      }}</span>
                    </div>
                    <input
                      type="number"
                      id="amount"
                      v-model="formData.amount"
                      required
                      :min="0"
                      :max="formData.is_percentage ? 100 : undefined"
                      :step="formData.is_percentage ? 1 : 0.01"
                      class="block w-full rounded-md border-gray-300 pl-7 focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                    />
                  </div>
                </div>

                <div class="relative flex items-start">
                  <div class="flex h-6 items-center">
                    <input
                      id="is_percentage"
                      v-model="formData.is_percentage"
                      type="checkbox"
                      class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                    />
                  </div>
                  <div class="ml-3 text-sm leading-6">
                    <label
                      for="is_percentage"
                      class="font-medium text-gray-900"
                    >
                      <!-- TODO Translate -->
                      Percentuale</label
                    >
                    <p class="text-gray-500">
                      <!-- TODO Translate -->
                      Imposta il valore come percentuale
                    </p>
                  </div>
                </div>
              </div>

              <div class="mt-5 sm:mt-6">
                <Button
                  type="submit"
                  class="inline-flex w-full justify-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
                >
                  {{ editingBudget ? "Update" : "Create" }} Budget
                </Button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
