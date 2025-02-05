<template>
  <div
    class="relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm hover:shadow-lg transition-shadow duration-300"
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
        @click="$emit('edit', category)"
        variant="secondary"
        size="sm"
        class="mr-2"
      >
        <PencilSquareIcon class="h-5 w-5" />
      </Button>
      <Button @click="$emit('delete', category)" variant="abort" size="sm">
        <TrashIcon class="h-5 w-5" />
      </Button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from "vue";
import Button from "./Button.vue";
import { PencilSquareIcon, TrashIcon } from "@heroicons/vue/24/outline";

const props = defineProps({
  category: {
    type: Object as () => { id: string; title: string; icon: string; color: string },
    required: true,
  },
});

defineEmits(["edit", "delete"]);
</script>
