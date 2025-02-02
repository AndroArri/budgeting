<script setup lang="ts">
import * as OutlineIcons from '@heroicons/vue/24/outline'

const icons = Object.entries(OutlineIcons).map(([name, component]) => ({
  name: name.replace(/Icon$/, ''),
  component
}))

defineProps<{
  modelValue: string
}>()

defineEmits(['update:modelValue'])
</script>

<template>
  <div class="grid grid-cols-6 gap-2">
    <button
      v-for="icon in icons"
      :key="icon.name"
      type="button"
      @click="$emit('update:modelValue', icon.name)"
      :class="[
        'p-2 rounded-md hover:bg-gray-100 flex items-center justify-center',
        modelValue === icon.name && 'bg-indigo-100 ring-2 ring-indigo-500'
      ]"
    >
      <component :is="icon.component" class="h-5 w-5" />
    </button>
  </div>
</template>