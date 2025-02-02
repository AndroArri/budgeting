
<template>
  <button
    :class="[
      'inline-flex items-center rounded-full px-2.5 py-0.5 text-sm font-semibold text-white shadow-sm',
      variant === 'primary' &&
        'block rounded-md bg-indigo-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-indigo-500',
      variant === 'abort' && 'bg-red-100 text-red-800',
      variant === 'warning' && 'bg-yellow-100 text-yellow-800',
      variant === 'info' && 'bg-blue-100 text-blue-800',
      variant === 'secondary' && 'bg-gray-100 text-gray-800',
    ]"
  >
    <slot name="icon-left"></slot>
    <slot></slot>
  </button>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    variant?: "primary" | "abort" | "warning" | "info" | "secondary";
  }>(),
  {
    variant: "secondary",
  }
);
</script>
