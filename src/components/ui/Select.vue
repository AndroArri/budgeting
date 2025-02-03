<template>
  <div>
    <label
      v-if="label"
      :for="id"
      class="block text-sm font-medium text-gray-700"
    >
      {{ label }}
    </label>
    <select
      :id="id"
      :value="modelValue"
      @change="onChange"
      :required="required"
      :disabled="disabled"
      :class="[
        'mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm',
        disabled && 'bg-gray-200 cursor-not-allowed',
        error && 'border-red-300 text-red-900 focus:border-red-500 focus:ring-red-500',
      ]"
      v-bind="$attrs"
    >
      <option v-if="placeholder" value="">{{ placeholder }}</option>
      <slot></slot>
    </select>
    <p v-if="error" class="mt-2 text-sm text-red-600">{{ error }}</p>
    <p v-if="hint" class="mt-2 text-sm text-gray-500">{{ hint }}</p>
  </div>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    modelValue: string | number;
    id?: string;
    label?: string;
    required?: boolean;
    disabled?: boolean;
    placeholder?: string;
    error?: string;
    hint?: string;
  }>(),
  {
    required: false,
    disabled: false,
  }
);

const emit = defineEmits(["update:modelValue"]);

function onChange(event: Event) {
  const target = event.target as HTMLInputElement;
  emit("update:modelValue", target.checked);
}

</script>
