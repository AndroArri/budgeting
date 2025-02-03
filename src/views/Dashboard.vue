<script setup lang="ts">
import { ref, onMounted, computed } from "vue";
import { supabase } from "../supabase/client";
import { format, startOfMonth, endOfMonth, subMonths } from "date-fns";
import { Line, Doughnut, Bar } from "vue-chartjs";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  BarElement,
} from "chart.js";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

interface Payment {
  id: string;
  title: string;
  price: number;
  date: string;
  category_id: string;
}

interface Category {
  id: string;
  title: string;
  color: string;
}

interface Budget {
  id: string;
  title: string;
  amount: number;
  category_id: string;
  is_percentage: boolean;
}

const payments = ref<Payment[]>([]);
const categories = ref<Category[]>([]);
const budgets = ref<Budget[]>([]);
const loading = ref(true);
const error = ref("");

// Get last 6 months of data
const monthlyData = computed(() => {
  const months: { [key: string]: number } = {};
  const today = new Date();

  // Initialize last 6 months with 0
  for (let i = 5; i >= 0; i--) {
    const month = subMonths(today, i);
    months[format(month, "MMM yyyy")] = 0;
  }

  // Sum payments by month
  payments.value.forEach((payment) => {
    const month = format(new Date(payment.date), "MMM yyyy");
    if (months[month] !== undefined) {
      months[month] += Number(payment.price);
    }
  });

  return {
    labels: Object.keys(months),
    datasets: [
      {
        label: "Monthly Expenses",
        data: Object.values(months),
        borderColor: "#4F46E5",
        backgroundColor: "#4F46E520",
        fill: true,
      },
    ],
  };
});

const categoryData = computed(() => {
  const categoryTotals: { [key: string]: number } = {};
  const categoryColors: { [key: string]: string } = {};

  categories.value.forEach((category) => {
    categoryTotals[category.title] = 0;
    categoryColors[category.title] = category.color;
  });

  payments.value.forEach((payment) => {
    const category = categories.value.find((c) => c.id === payment.category_id);
    if (category) {
      categoryTotals[category.title] =
        (categoryTotals[category.title] || 0) + Number(payment.price);
    }
  });

  return {
    labels: Object.keys(categoryTotals),
    datasets: [
      {
        data: Object.values(categoryTotals),
        backgroundColor: Object.values(categoryColors),
      },
    ],
  };
});

const budgetData = computed(() => {
  const budgetStatus: { [key: string]: { budget: number; spent: number } } = {};

  // Initialize budget status
  budgets.value.forEach((budget) => {
    const category = categories.value.find((c) => c.id === budget.category_id);
    if (category) {
      budgetStatus[category.title] = {
        budget: Number(budget.amount),
        spent: 0,
      };
    }
  });

  // Calculate spent amount for current month
  const startMonth = startOfMonth(new Date());
  const endMonth = endOfMonth(new Date());

  payments.value.forEach((payment) => {
    const paymentDate = new Date(payment.date);
    if (paymentDate >= startMonth && paymentDate <= endMonth) {
      const category = categories.value.find(
        (c) => c.id === payment.category_id
      );
      if (category && budgetStatus[category.title]) {
        budgetStatus[category.title].spent += Number(payment.price);
      }
    }
  });

  return {
    labels: Object.keys(budgetStatus),
    datasets: [
      {
        label: "Budget",
        data: Object.values(budgetStatus).map((status) => status.budget),
        backgroundColor: "#4F46E5",
      },
      {
        label: "Spent",
        data: Object.values(budgetStatus).map((status) => status.spent),
        backgroundColor: "#EF4444",
      },
    ],
  };
});

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
};

async function fetchData() {
  try {
    loading.value = true;
    error.value = "";

    // Fetch categories
    const { data: categoriesData, error: categoriesError } = await supabase
      .from("categories")
      .select("*");

    if (categoriesError) throw categoriesError;
    categories.value = categoriesData;

    // Fetch payments for last 6 months
    const sixMonthsAgo = subMonths(new Date(), 6);
    const { data: paymentsData, error: paymentsError } = await supabase
      .from("payments")
      .select("*")
      .gte("date", format(sixMonthsAgo, "yyyy-MM-dd"))
      .order("date", { ascending: true });

    if (paymentsError) throw paymentsError;
    payments.value = paymentsData;

    // Fetch budgets
    const { data: budgetsData, error: budgetsError } = await supabase
      .from("budgets")
      .select("*");

    if (budgetsError) throw budgetsError;
    budgets.value = budgetsData.map((budget) => ({
      ...budget,
      is_percentage: budget.is_percentage ?? false,
    }));
  } catch (e) {
    error.value = "Errore nel caricamento dei dati della dashboard";
    console.error("Error:", e);
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  fetchData();
});
</script>

<template>
  <div>
    <h1 class="text-2xl font-semibold text-gray-900">Cruscotto</h1>

    <!-- Error Alert -->
    <div v-if="error" class="mt-4 rounded-md bg-red-50 p-4">
      <div class="text-sm text-red-700">{{ error }}</div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="mt-6 text-center">
      <div class="text-sm text-gray-500">Caricamento dati della dashboard...</div>
    </div>

    <!-- Dashboard Content -->
    <div v-else class="mt-6 grid grid-cols-1 gap-6 lg:grid-cols-2">
      <!-- Monthly Expenses Chart -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-medium text-gray-900 mb-4">Spese Mensili</h2>
        <div class="h-80">
          <Line :data="monthlyData" :options="chartOptions" />
        </div>
      </div>

      <!-- Expenses by Category Chart -->
      <div class="bg-white p-6 rounded-lg shadow">
        <h2 class="text-lg font-medium text-gray-900 mb-4">
          Spese per Categoria
        </h2>
        <div class="h-80">
          <Doughnut :data="categoryData" :options="chartOptions" />
        </div>
      </div>

      <!-- Budget Status Chart -->
      <div class="bg-white p-6 rounded-lg shadow lg:col-span-2">
        <h2 class="text-lg font-medium text-gray-900 mb-4">
          Stato del Budget (Mese Corrente)
        </h2>
        <div class="h-80">
          <Bar :data="budgetData" :options="chartOptions" />
        </div>
      </div>
    </div>
  </div>
</template>
