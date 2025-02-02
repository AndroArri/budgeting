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
import Modal from "../components/ui/Modal.vue";
import Table from "../components/ui/Table.vue";
import Checkbox from "../components/ui/Checkbox.vue";
import Alert from "../components/ui/Alert.vue";
import Badge from "../components/ui/Badge.vue";

interface Income {
  id: string;
  title: string;
  price: number;
  is_personal: boolean | null;
  created_at: string | null;
  user_id: string;
}

const incomes = ref<Income[]>([]);
const loading = ref(true);
const error = ref("");
const success = ref("");
const showModal = ref(false);
const editingIncome = ref<Income | null>(null);
const formData = ref({
  title: "",
  price: 0,
  is_personal: false,
});

const tableColumns = [
  { key: "title", label: "Title" },
  { key: "price", label: "Amount", align: "right" as const },
  { key: "is_personal", label: "Personal", align: "center" as const },
  { key: "actions", label: "", align: "right" as const },
];

async function fetchIncomes() {
  try {
    loading.value = true;
    error.value = "";

    const { data, error: err } = await supabase
      .from("incomes")
      .select("*")
      .order("created_at", { ascending: false });

    if (err) throw err;
    incomes.value = data || [];
  } catch (e) {
    error.value = "Error loading incomes";
    console.error("Error:", e);
  } finally {
    loading.value = false;
  }
}

function openModal(income: Income | null = null) {
  if (income) {
    editingIncome.value = income;
    formData.value = {
      title: income.title,
      price: income.price,
      is_personal: income.is_personal ?? false,
    };
  } else {
    editingIncome.value = null;
    formData.value = {
      title: "",
      price: 0,
      is_personal: false,
    };
  }
  showModal.value = true;
}

async function handleSubmit() {
  try {
    error.value = "";
    success.value = "";

    if (editingIncome.value) {
      const { error: err } = await supabase
        .from("incomes")
        .update({
          title: formData.value.title,
          price: formData.value.price,
          is_personal: formData.value.is_personal,
        })
        .eq("id", editingIncome.value.id);

      if (err) throw err;
      success.value = "Income updated successfully";
    } else {
      const user = await supabase.auth.getUser();
      const user_id = user.data.user?.id;
      if (!user_id) throw new Error("User not found");

      const { error: err } = await supabase.from("incomes").insert({
        title: formData.value.title,
        price: formData.value.price,
        is_personal: formData.value.is_personal,
        user_id,
      });

      if (err) throw err;
      success.value = "Income created successfully";
    }

    showModal.value = false;
    await fetchIncomes();
  } catch (e) {
    error.value = "Error saving income";
    console.error("Error:", e);
  }
}

async function deleteIncome(id: string) {
  if (!confirm("Are you sure you want to delete this income?")) return;

  try {
    error.value = "";
    const { error: err } = await supabase.from("incomes").delete().eq("id", id);

    if (err) throw err;
    success.value = "Income deleted successfully";
    await fetchIncomes();
  } catch (e) {
    error.value = "Error deleting income";
    console.error("Error:", e);
  }
}

onMounted(() => {
  fetchIncomes();
});
</script>

<template>
  <div>
    <div class="sm:flex sm:items-center">
      <div class="sm:flex-auto">
        <h1 class="text-2xl font-semibold text-gray-900">Income</h1>
        <p class="mt-2 text-sm text-gray-700">Manage your income sources</p>
      </div>
      <div class="mt-4 sm:ml-16 sm:mt-0 sm:flex-none">
        <Button @click="openModal()" variant="primary">
          <template #icon-left>
            <PlusIcon class="h-5 w-5" />
          </template>
          Add Income
        </Button>
      </div>
    </div>

    <Alert v-if="success" variant="success" class="mt-4">
      {{ success }}
    </Alert>

    <Alert v-if="error" variant="error" class="mt-4">
      {{ error }}
    </Alert>

    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Loading incomes...</div>
    </div>

    <Table v-else class="mt-8" :columns="tableColumns" :items="incomes">
      <template #price="{ item }"> €{{ item.price.toFixed(2) }} </template>

      <template #is_personal="{ item }">
        <Badge :variant="item.is_personal ? 'success' : 'gray'">
          {{ item.is_personal ? "Yes" : "No" }}
        </Badge>
      </template>

      <template #actions="{ item }">
        <Button @click="openModal(item)" variant="secondary" size="sm" class="mr-2">
          <PencilSquareIcon class="h-5 w-5" />
        </Button>
        <Button @click="deleteIncome(item.id)" variant="abort" size="sm">
          <TrashIcon class="h-5 w-5" />
        </Button>
      </template>
    </Table>

    <Modal
      v-model="showModal"
      :title="editingIncome ? 'Edit Income' : 'Add Income'"
    >
      <form @submit.prevent="handleSubmit" class="space-y-4">
        <Input v-model="formData.title" label="Title" required />

        <Input
          v-model="formData.price"
          type="number"
          label="Amount"
          prefix="€"
          required
          min="0"
          step="0.01"
        />

        <Checkbox
          v-model="formData.is_personal"
          label="Personal income"
          description="Mark this income as personal"
        />
      </form>

      <template #footer>
        <Button
          type="submit"
          variant="primary"
          class="ml-3"
          @click="handleSubmit"
        >
          {{ editingIncome ? "Update" : "Create" }} Income
        </Button>
        <Button @click="showModal = false" variant="secondary"> Cancel </Button>
      </template>
    </Modal>
  </div>
</template>
