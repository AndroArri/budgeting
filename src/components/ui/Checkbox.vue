<template>
    <div class="relative flex items-start">
      <div class="flex h-6 items-center">
        <input
          :id="id"
          type="checkbox"
          :checked="modelValue"
          @change="onChange"
          :required="required"
          :disabled="disabled"
          class="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
          v-bind="$attrs"
        />
      </div>
      <div class="ml-3 text-sm leading-6">
        <label :for="id" class="font-medium text-gray-900">{{ label }}</label>
        <p v-if="description" class="text-gray-500">{{ description }}</p>
      </div>
    </div>
  </template>
  
  <script setup lang="ts">
  withDefaults(defineProps<{
    modelValue: boolean
    id?: string
    label?: string
    description?: string
    required?: boolean
    disabled?: boolean
  }>(), {
    required: false,
    disabled: false
  })
  
  const emit = defineEmits(['update:modelValue']);
  
  function onChange(event: Event) {
    const target = event.target as HTMLInputElement;
    emit('update:modelValue', target.checked);
  }
  </script>