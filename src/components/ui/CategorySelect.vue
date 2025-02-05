<template>
  <Select v-model="modelValue" required>
    <option v-for="category in categories" :key="category.id" :value="category.id">
      {{ category.icon }} {{ category.title }}
    </option>
  </Select>
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import Select from "./Select.vue";
import { supabase } from "../../supabase/client";

const props = defineProps({
  modelValue: String,
});

const emit = defineEmits(["update:modelValue"]);

const categories = ref([]);

async function fetchCategories() {
  const { data, error } = await supabase
    .from("categories")
    .select("*")
    .order("title", { ascending: true });

  if (error) {
    console.error("Error loading categories:", error);
    return;
  }

  categories.value = data;
}

onMounted(() => {
  fetchCategories();
});
</script>
